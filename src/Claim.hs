{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}

module Claim where
import qualified Cardano.Api                     as Api (writeFileTextEnvelope)
import qualified Cardano.Api.Shelley             as Api
import           Cardano.Ledger.BaseTypes        (Network (..))
import           Cardano.Ledger.Credential       (Credential (ScriptHashObj),
                                                  StakeReference (StakeRefNull))
import           Codec.Serialise                 (Serialise, serialise)
import qualified Data.ByteString.Char8           as BS8
import qualified Data.ByteString.Lazy            as BSL
import qualified Data.ByteString.Short           as BSS
import           Data.Functor                    (void)
import qualified Data.Text                       as Text
import qualified Plutus.Script.Utils.V2.Contexts as C (ScriptContext (scriptContextTxInfo),
                                                       TxInfo, TxOut,
                                                       ownCurrencySymbol,
                                                       txInfoMint,
                                                       txInfoOutputs,
                                                       txInfoSignatories,
                                                       txOutAddress, txSignedBy)
import qualified Plutus.Script.Utils.V2.Scripts  as Scripts (ValidatorHash,
                                                             validatorHash)
import           Plutus.V1.Ledger.Address        as V1Address (Address,
                                                               addressCredential,
                                                               scriptHashAddress)
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
import           Prelude                         as P (IO, String)
import           Utilities


{-# INLINABLE mkClaimValidator #-}
mkClaimValidator:: PubKeyHash -> PubKeyHash -> TokenName -> C.ScriptContext -> Bool
mkClaimValidator storePkh treasuryPkh tokename sContext = traceIfFalse "Failed pubKeyHash validation." (checkSignature storePkh && checkSignature treasuryPkh) &&
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
        checkSignatories = length [x | x <- C.txInfoSignatories txInfo, x == treasuryPkh || x == storePkh] == 2


{-# INLINABLE  mkWrappedParameterizedValidator #-}
mkWrappedParameterizedValidator:: PubKeyHash -> BuiltinData -> BuiltinData -> BuiltinData -> ()
mkWrappedParameterizedValidator = wrapValidator . mkClaimValidator

parameterizedValidator :: PubKeyHash -> Validator
parameterizedValidator pkh = mkValidatorScript ($$(compile [|| mkWrappedParameterizedValidator ||]) `applyCode` liftCode pkh)


-- Serialization
saveClaimValidator :: Validator -> IO ()
saveClaimValidator claimValidator = void $ Api.writeFileTextEnvelope  "./validator/claimValidator.plutus" Nothing (serialisedValidator claimValidator)

writeRedeemerJson :: IO ()
writeRedeemerJson = writeJSON "./claimRedeemer.json" (True :: Bool)

hashScript :: Api.PlutusScript Api.PlutusScriptV2 -> Api.ScriptHash
hashScript = Api.hashScript . Api.PlutusScript Api.PlutusScriptV2

validatorHash :: Validator -> Api.ScriptHash
validatorHash = hashScript . validatorToScript

validatorToScript :: Validator -> Api.PlutusScript Api.PlutusScriptV2
validatorToScript = serializableToScript

serializableToScript :: Serialise a => a -> Api.PlutusScript Api.PlutusScriptV2
serializableToScript = Api.PlutusScriptSerialised . BSS.toShort . BSL.toStrict . serialise

validatorAddressBech32 :: Network -> Validator -> String
validatorAddressBech32 network v =
    Text.unpack $
    Api.serialiseToBech32 $
    Api.ShelleyAddress
      network
      (ScriptHashObj $ Api.toShelleyScriptHash $ validatorHash v)
      StakeRefNull

