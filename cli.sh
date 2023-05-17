#create an address for the plutus script contract
cardano-cli address build --payment-script-file xxx.plutus $TESTNET --out-file xxx.addr

cardano-cli transaction build \
--babbage-era $TESTNET \
--tx-in $utxoin \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--tx-out-datum-hash-file unit.json \
--change-address $Adr01 \
--protocol-params-file protocol.params \
--out-file mintTx.body

cardano-cli transaction sign \
--tx-body-file give.unsigned \
--signing-key-file Wallet/addr.skey $TESTNET \
--out-file give.signed

cardano-cli transaction submit $TESTNET \
--tx-file give.signed

#grab
cardano-cli transaction build \
--babbage-era $TESTNET \
--tx-in $utxoin \
--tx-in-script-file AS.plutus \
--tx-in-datum-file unit.json \
--tx-in-redeemer-file unit.json \
--required-signer-hash $signerPKH \
--tx-in-collateral $collateral \
--tx-out $Adr01+$output \
--change-address $nami \
--protocol-params-file protocol.params \
--out-file grab.body

## note that collateral is actually a utxo reference and not a value
## the one who provides the collateral is the one who will sign the transaction

cardano-cli transaction sign \
--tx-body-file grab.unsigned \
--signing-key-file Wallet/Adr01.skey $TESTNET \
--out-file grab.signed

cardano-cli transaction submit $TESTNET \
--tx-file grab.signed
