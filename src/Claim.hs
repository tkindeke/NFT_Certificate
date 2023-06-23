{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}

module Claim where

import           Cardano.Api                     (writeFileTextEnvelope)
import           Data.Functor                    (void)
import qualified Plutus.Script.Utils.V2.Contexts as C (ScriptContext (scriptContextTxInfo),
                                                       TxInfo, TxOut,
                                                       ownCurrencySymbol,
                                                       txInfoMint,
                                                       txInfoOutputs,
                                                       txInfoSignatories,
                                                       txOutAddress, txSignedBy)
import qualified Plutus.Script.Utils.V2.Scripts  as Scripts ()
import           Plutus.V1.Ledger.Address        as V1Address (addressCredential)
import           Plutus.V1.Ledger.Scripts
import           Plutus.V1.Ledger.Value
import           Plutus.V2.Ledger.Api            as PlutusV2 (BuiltinData,
                                                              Credential (PubKeyCredential),
                                                              PubKeyHash)
import           PlutusTx                        (applyCode, compile, liftCode,
                                                  makeLift)
import qualified PlutusTx.Builtins.Internal      as BI ()
import           PlutusTx.Prelude                (Bool (False, True), Integer,
                                                  Maybe (Nothing), length, ($),
                                                  (&&), (.), (==), (||))
import           PlutusTx.Trace                  (traceIfFalse)
import           Prelude                         as P (IO)
import           Utilities

data ClaimParams = ClaimParams
    { store    :: PubKeyHash
    , treasury :: PubKeyHash
    }
makeLift ''ClaimParams

{-# INLINABLE mkClaimValidator #-}
mkClaimValidator:: ClaimParams -> Datum -> TokenName -> C.ScriptContext -> Bool
mkClaimValidator params datum tokename sContext = traceIfFalse "Failed pubKeyHash validation." (checkSignature (store params) && checkSignature (treasury params)) &&
                                                traceIfFalse "Failed max mint amount validation." (checkAssetAmount 1) &&
                                                traceIfFalse "Failed signatories validation." checkSignatories
      where
        txInfo :: C.TxInfo
        txInfo = C.scriptContextTxInfo sContext

        -- check that transaction is being signed by pubkeyhash
        checkSignature :: PubKeyHash -> Bool
        checkSignature = C.txSignedBy txInfo

        -- check asset amount
        checkAssetAmount :: Integer -> Bool
        checkAssetAmount amount =
          case flattenValue (C.txInfoMint txInfo) of
            [(cs, tn, amt)] -> cs == C.ownCurrencySymbol sContext && amt == amount && tn == tokename
            _              -> False

        -- check transaction signatories
        checkSignatories :: Bool
        checkSignatories = length [x | x <- C.txInfoSignatories txInfo, x == treasury params || x == store params] == 2


{-# INLINABLE  mkWrappedParameterizedValidator #-}
mkWrappedParameterizedValidator:: ClaimParams -> BuiltinData -> BuiltinData -> BuiltinData -> ()
mkWrappedParameterizedValidator = wrapValidator . mkClaimValidator

parameterizedValidator :: ClaimParams -> Validator
parameterizedValidator params = mkValidatorScript ($$(compile [|| mkWrappedParameterizedValidator ||]) `applyCode` liftCode params)

saveClaimValidator :: Validator -> IO ()
saveClaimValidator claimValidator = void $ writeFileTextEnvelope  "validator/claimValidator.plutus" Nothing (serialisedValidator claimValidator)

writeRedeemerJson :: IO ()
writeRedeemerJson = writeJSON "./claimRedeemer.json" (True :: Bool)

