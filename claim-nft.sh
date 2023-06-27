
#!/bin/bash

#test if jq is installed
test_jq=$(echo "{ }" | jq)
if [ "$test_jq" != "{}" ]; then
        echo "jq not installed"
        exit 1
fi

tokenAmount="1"
# output=54385626
storeAddress=$(cat addr/store.addr)
treasuryAddress=$(cat addr/treasury.addr)
validatorScript="validator/claimValidator.plutus"
storePkh=$(cat keys/store.pkh)
treasuryPkh=$(cat keys/treasury.pkh)
testMagic=2
redeemerFile=redeemer.json 


# function mintAsset ()
# {
#   local assetName=$1
#   local hex_tokenname=$2
#   local metadataPath=$3
#   local txBodyPath=transactions/$assetName.body
#   local txSignedPath=transactions/$assetName.signed
#   local redeemerFile=redeemer.json 
#   local protocolJson=protocol.json

#   echo $treasuryAddress

#   cardano-cli transaction build \
#     --babbage-era \
#     --tx-in $utxo \
#     --required-signer-hash $storePkh \
#     --tx-in-collateral $collateral \
#     --mint "$tokenAmount $policyID.$hex_tokenname" \
#     --mint-script-file $policyScript\
#     --metadata-json-file $metadataPath \
#     --mint-redeemer-file $redeemerFile \
#     --tx-out "$treasuryAddress+$output+$tokenAmount $policyID.$hex_tokenname" \
#     --change-address $storeAddress \
#     --protocol-params-file $protocolJson \
#     --invalid-hereafter 21243662 \
#     --out-file $txBodyPath \
#     --testnet-magic 2

#   cardano-cli transaction sign --testnet-magic 2 \
#     --signing-key-file "keys/store.skey" \
#     --tx-body-file $txBodyPath \
#     --out-file $txSignedPath

#   cardano-cli transaction submit --testnet-magic 2 \
#     --tx-file $txSignedPath

#   txid=$(cardano-cli transaction txid --tx-file $txSignedPath)

#   echo "Transaction id : "$txid
# }

# for f in $metadataPath;do

#   assetName=$(jq '."721"."'$policyID'".Ketchiz.name' $f | tr -d '"\n')
#   hex_tokenname=$(echo -n $assetName | xxd -b -ps -c 80 | tr -d '"\n')
  
#   echo ""
#   echo Please provide a UTXO to be consumed in your transaction following this format "-> TxHash#TxIx"
#   echo ""
#   cardano-cli query utxo --testnet-magic $testMagic --address $storeAddress
#   read utxo;

#   echo ""
#   echo Please provide a UTXO to be used as a collateral following this format "-> TxHash#TxIx"
#   echo ""
#   cardano-cli query utxo --testnet-magic $testMagic --address $storeAddress
#   read collateral;

#   mintAsset $assetName $hex_tokenname $f

#   read -t 60 

# done;

# echo "assets have been minted successfully!"

  
  echo ""
  echo Please provide a UTXO to be consumed in your transaction following this format "-> TxHash#TxIx"
  echo ""
  cardano-cli query utxo --testnet-magic $testMagic --address $treasuryAddress
  read utxo;

  echo ""
  echo Please provide a UTXO to be used as a collateral following this format "-> TxHash#TxIx"
  echo ""
  cardano-cli query utxo --testnet-magic $testMagic --address $treasuryAddress
  read collateral;


  cardano-cli transaction build \
    --babbage-era \
    --tx-in $utxo \
    --required-signer-hash $storePkh \
    --required-signer-hash $treasuryPkh \
    --tx-in-collateral $collateral \
    --tx-out "$treasuryAddress+$output+$tokenAmount $policyID.$hex_tokenname" \
    --change-address $storeAddress \
    --protocol-params-file $protocolJson \
    --out-file $txBodyPath \
    --testnet-magic 2

  cardano-cli transaction sign --testnet-magic 2 \
    --signing-key-file "keys/store.skey" \
    --tx-body-file $txBodyPath \
    --out-file $txSignedPath

  cardano-cli transaction submit --testnet-magic 2 \
    --tx-file $txSignedPath

  txid=$(cardano-cli transaction txid --tx-file $txSignedPath)

  echo "Transaction id : "$txid