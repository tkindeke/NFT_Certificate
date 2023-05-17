{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module NFT_Certificate where

import           Cardano.Api                    (PlutusScript, PlutusScriptV2,
                                                 writeFileTextEnvelope)
import           Cardano.Api.Shelley            (PlutusScript (..),
                                                 ScriptDataJsonSchema (ScriptDataJsonDetailedSchema),
                                                 fromPlutusData,
                                                 scriptDataToJson)
import           Codec.Serialise
import           Data.Aeson                     as A
import qualified Data.ByteString.Lazy           as LBS
import qualified Data.ByteString.Short          as SBS
import           Data.Functor                   (void)
import           Ledger                         hiding (singleton)
import           Ledger.Constraints             as Constraints
import qualified Plutus.Script.Utils.V2.Scripts as Scripts
import           Plutus.V1.Ledger.Address       as V1Address
import           Plutus.V2.Ledger.Api
import           PlutusTx                       (Data (..))
import qualified PlutusTx
import qualified PlutusTx.Builtins              as Builtins
import           PlutusTx.Prelude               hiding (Semigroup (..), unless)
import           Prelude                        (FilePath, IO, Semigroup (..),
                                                 String, show)


{-# INLINABLE mkMintPolicy #-}
mkMintPolicy:: BuiltinData -> BuiltinData -> ()
mkMintPolicy _ _ = ()
    -- check that store wallet pubkeyhash is running transaction
    -- check that transaction has a dead line (time range)
    -- check that nft has not yet been minted (uniqueness), serial number as parameter
    -- check that you're only minting one asset per transaction
    -- check that datum is equal to redeemer

mintPolicy:: MintingPolicy
mintPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| mkMintPolicy ||])

mintPolicySBS :: SBS.ShortByteString
mintPolicySBS = SBS.toShort . LBS.toStrict $ serialise mintPolicy

serialisedPolicy :: PlutusScript PlutusScriptV2
serialisedPolicy = PlutusScriptSerialised mintPolicySBS

saveMintPolicy :: IO ()
saveMintPolicy = void $ writeFileTextEnvelope  "policy/mintPolicy.plutus" Nothing serialisedPolicy


-- mintPolicyToPlutusScript :: () -> IO()
-- mintPolicyToPlutusScript mp = _
--     where
--         mintPolicy:: MintingPolicy
--         mintPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| mp ||])

--         mintPolicyToSBS :: MintingPolicy -> SBS.ShortByteString
--         mintPolicyToSBS mp = SBS.toShort . LBS.toStrict $ serialise mp

--         serialiseToPlutusScript :: SBS.ShortByteString -> PlutusScript PlutusScriptV2
--         serialiseToPlutusScript sbs = PlutusScriptSerialised sbs


-- {-# INLINABLE alwaysSucceeds #-}
-- alwaysSucceeds :: BuiltinData -> BuiltinData -> BuiltinData -> ()
-- alwaysSucceeds _ _ _ = ()

-- validator :: Validator
-- validator = mkValidatorScript $$(PlutusTx.compile [|| alwaysSucceeds ||])


-- -- valHash :: Ledger.ValidatorHash
-- -- valHash = Scripts.validatorHash validator
-- -- scrAddress :: V1Address.Address
-- -- scrAddress = V1Address.scriptHashAddress valHash

-- -- serialise as short byte string
-- scriptSBS :: SBS.ShortByteString
-- scriptSBS = SBS.toShort . LBS.toStrict $ serialise validator

-- -- serialise as serialised script
-- serialisedScript :: PlutusScript PlutusScriptV2
-- serialisedScript = PlutusScriptSerialised scriptSBS

-- writeSerialisedScript :: IO ()
-- writeSerialisedScript = void $ writeFileTextEnvelope "validator.plutus" Nothing serialisedScript



-- writeJSON :: PlutusTx.ToData a => FilePath -> a -> IO()
-- writeJSON file = LBS.writeFile file . A.encode . scriptDataToJson ScriptDataJsonDetailedSchema . fromPlutusData . PlutusTx.toData

-- writeUnit :: IO()
-- writeUnit = writeJSON "unit.json" ()



