
#!/bin/bash

#test if jq is installed
test_jq=$(echo "{ }" | jq)
if [ "$test_jq" != "{}" ]; then
        echo "jq not installed"
        exit 1
fi

tokenAmount="1"
output=54385626
policyID=$(cat policy/policyID)
storeAddress=$(cat addr/store.addr)
treasuryAddress=$(cat addr/treasury.addr)
policyScript="policy/mintPolicy.plutus"
metadataPath="assets/metadata/*.json"
testMagic=2

function mintAsset ()
{
  cardano-cli transaction build \
    --babbage-era \
    --tx-in $utxo \
    --tx-in-collateral $utxo \
    --mint="$tokenAmount $policyID.$2" \
    --mint-script-file $policyScript\
    --metadata-json-file $3 \
    --mint-redeemer-file unit.json \
    --tx-out $treasuryAddress+$output+"$tokenAmount $policyID.$2" \
    --protocol-params-file protocol.json \
    --out-file "transactions/"$1".body" \
    --change-address $storeAddress \
    --testnet-magic $testMagic

  cardano-cli transaction sign --testnet-magic $testMagic \
    --signing-key-file "keys/store.skey" \
    --tx-body-file "transactions/"$1".body"\
    --out-file "transactions/"$1".signed"

  cardano-cli transaction submit --testnet-magic $testMagic \
    --tx-file "transactions/"$1".signed"
  
  txid=cardano-cli transaction txid --tx-file "transactions/"$1".signed"

  echo $txid
}

for f in $metadataPath;do

  assetName=$(jq '."721".'$policyID'.Ketchiz.name' $f)
  hex_tokenname=$(echo -n $assetName | xxd -b -ps -c 80 | tr -d '\n')

  echo ""
  echo Please provide UTXO to be consumed in your transaction following this format "-> TxHash#TxIx"
  echo ""
  cardano-cli query utxo --testnet-magic $testMagic --address $storeAddress
  read utxo;

  mintAsset $assetName $hex_tokenname $f

  read -t 60 

done;

echo "assets have been minted successfully!"
