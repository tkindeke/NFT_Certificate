#!/bin/bash

if [[ ! $1 || ! $2 ]]; then
    echo "Error: missing parameter(s)"
    echo "you should provide a name parameter for your keys and address"
    echo "and also provide a true or false value to enable staking or not"
    exit 1
fi

name="$1"
isStakingEnabled="$2"
keyPairPath="../nft_certificate/keys/${name}"
addrPath="../nft_certificate/addr/${name}"
testnetMagic="--testnet-magic 2"

cardano-cli address key-gen \
--verification-key-file "${keyPairPath}.vkey" \
--signing-key-file "${keyPairPath}.skey" 

if [[ isStakingEnabled == "true" ]]; then
    cardano-cli address key-gen \
    --verification-key-file "${keyPairPath}_stake.vkey" \
    --signing-key-file "${keyPairPath}_stake.skey" 

    cardano-cli address build \
    --payment-verification-key-file "${keyPairPath}.vkey" \
    --stake-verification-key-file "${keyPairPath}_stake.vkey" \
    --out-file "${addrPath}.addr" \ 
    $testnetMagic
else
    cardano-cli address build \
    --payment-verification-key-file "${keyPairPath}.vkey" \
    --out-file "${addrPath}.addr" $testnetMagic
fi

echo "address created!"