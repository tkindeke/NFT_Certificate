
#!/bin/bash

#test if jq is installed
test_json=$(echo "{ }" | jq)
if [ "$test_json" != "{}" ]; then
        echo "jq not installed"
        exit 1
fi

declare -a assetsToMint=("iNUD9hTaSL5Z" "CkicQ2XggpB6" "W2ceXZ62bDoM" "EyP4DUk6W5K2" "QN3jH9QjjHY8")
tokenAmount="1"
output=54385626
policyID=$(cat policy/policyID)
storeAddress=$(cat addr/store.addr)
treasuryAddress=$(cat addr/treasury.addr)
policyScript="policy/mintPolicy.plutus"

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
    --testnet-magic 2

  cardano-cli transaction sign --testnet-magic 2 \
    --signing-key-file "keys/store.skey" \
    --tx-body-file "transactions/"$1".body"\
    --out-file "transactions/"$1".signed"

  cardano-cli transaction submit --testnet-magic 2 \
    --tx-file "transactions/"$1".signed"
}

for ((i=0; i<${#assetsToMint[*]}; i++));do

  assetName=${assetsToMint[$i]} 
  assetMetadata="assets/metadata/"$assetName".json"
  hex_tokenname=$(echo -n $(jq '."721".'$policyID'.Ketchiz.name' $assetMetadata) | xxd -b -ps -c 80 | tr -d '\n')
  
  echo ""
  echo Please provide UTXO to be consumed in your transaction following this format "-> TxHash#TxIx"
  echo ""
  cardano-cli query utxo --testnet-magic 2 --address $storeAddress
  read utxo;

  mintAsset $assetName $hex_tokenname $assetMetadata

  read -t 60 

done;
