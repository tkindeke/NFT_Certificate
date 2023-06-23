{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}

module Premint where

import           Cardano.Api                     (writeFileTextEnvelope)
import           Data.Functor                    (void)
import qualified Plutus.Script.Utils.V2.Contexts as C (ScriptContext (scriptContextTxInfo),
                                                       TxInfo, TxOut,
                                                       ownCurrencySymbol,
                                                       txInfoMint,
                                                       txInfoOutputs,
                                                       txInfoValidRange,
                                                       txOutAddress, txSignedBy)
import qualified Plutus.Script.Utils.V2.Scripts  as Scripts ()
import           Plutus.V1.Ledger.Address        as V1Address (addressCredential)
import           Plutus.V1.Ledger.Interval
import           Plutus.V1.Ledger.Scripts
import           Plutus.V1.Ledger.Value
import           Plutus.V2.Ledger.Api            as PlutusV2 (BuiltinData,
                                                              Credential (PubKeyCredential),
                                                              POSIXTime,
                                                              PubKeyHash)
import           PlutusTx                        (applyCode, compile, liftCode,
                                                  makeLift)
import qualified PlutusTx.Builtins.Internal      as BI ()
import           PlutusTx.Prelude                (Bool (False, True), Integer,
                                                  Maybe (Nothing), length, ($),
                                                  (&&), (-), (.), (==), (||))
import           PlutusTx.Trace                  (traceIfFalse)
import           Prelude                         as P (IO)
import           Utilities

data PremintParams = PremintParams
    { store    :: PubKeyHash
    , treasury :: PubKeyHash
    , deadline:: POSIXTime
    }
makeLift ''PremintParams

{-# INLINABLE mkMintPolicy #-}
mkMintPolicy:: PremintParams -> Bool -> C.ScriptContext -> Bool
mkMintPolicy params isMint sContext =
      if isMint then
        traceIfFalse "Failed pubKeyHash validation." (checkSignature (store params)) &&
        traceIfFalse "Failed max mint amount validation." (checkAssetAmount 1) &&
        traceIfFalse "Failed transaction time range validation." checkTransactionDeadline &&
        traceIfFalse "Failed output address validation." checkOutputPubKeyHashes
      else
        traceIfFalse "Failed pubKeyHash validation." (checkSignature (treasury params))  &&
        traceIfFalse "Failed burn amount validation." (checkAssetAmount (-1))
      where
        txInfo :: C.TxInfo
        txInfo = C.scriptContextTxInfo sContext

        txOutputs::[C.TxOut]
        txOutputs = C.txInfoOutputs txInfo

        -- check that transaction is being signed by pubkeyhash
        checkSignature :: PubKeyHash -> Bool
        checkSignature = C.txSignedBy txInfo

        -- check asset amount
        checkAssetAmount :: Integer -> Bool
        checkAssetAmount amount =
          case flattenValue (C.txInfoMint txInfo) of
            [(cs, _, amt)] -> cs == C.ownCurrencySymbol sContext && amt == amount
            _              -> False

        -- check transaction time range
        checkTransactionDeadline:: Bool
        checkTransactionDeadline = contains (to $ deadline params) (C.txInfoValidRange txInfo)

        -- check transaction outputs
        checkOutputPubKeyHashes :: Bool
        checkOutputPubKeyHashes = length [x | x <- txOutputs, hasPubKeyHash x (treasury params) || hasPubKeyHash x (store params)] == length txOutputs


{-# INLINABLE hasPubKeyHash #-}
hasPubKeyHash::C.TxOut -> PubKeyHash -> Bool
hasPubKeyHash txOut' pkh =
  case addressCredential $ C.txOutAddress txOut' of
    PubKeyCredential x -> x == pkh
    _                  -> False

{-# INLINABLE  mkWrappedParameterizedMintPolicy #-}
mkWrappedParameterizedMintPolicy :: PremintParams -> BuiltinData -> BuiltinData -> ()
mkWrappedParameterizedMintPolicy = wrapPolicy . mkMintPolicy

parameterizedPolicy :: PremintParams -> MintingPolicy
parameterizedPolicy params = mkMintingPolicyScript ($$(compile [|| mkWrappedParameterizedMintPolicy ||]) `applyCode` liftCode params)

saveMintPolicy :: MintingPolicy -> IO ()
saveMintPolicy mintPolicy = void $ writeFileTextEnvelope  "policy/mintPolicy.plutus" Nothing (serialisedPolicy mintPolicy)

writeRedeemerJson :: IO ()
writeRedeemerJson = writeJSON "./redeemer.json" (True :: Bool)

