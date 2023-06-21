# NFT_Certificate

This application was built as an assessment for the Cardano Developer Professional program, given by Emurgo Academy.<br/>
The project aims to show the mastery of the implementation of smart contracts using Plutus.<br/>
Being inspired by a student in a different cohort, I came up with the idea of implementing a smart contract that generates an authenticity nft certificate on item purchase.<br/><br/>
> **Note:**<br/>
*This project will not include the front-end implementation. The main focus will be put on the off-chain code that will build transactions using cardano-cli commands, and on-chain code that will validate transactions using Plutus libraries.*
<br/><br/>
# How it works

**PREMINT** <br/><br/>
Before publishing products to be sold on the online website, a script will be run to premint a nft certificate per product. Minted assets will be send to a treasury address where each asset name will be refering to a product serial number. The script will be building a transaction per asset to be minted.   
In this process, a minting policy script will be running on each transaction to ensure that the below conditions are met: 
<ul>
  <li>only the store wallet is allowed to mint assets</li>
  <li>the transaction only mints one asset</li>
  <li>the asset to be minted must be unique</li>
  <li>the minted asset is send to the treasury address</li>
</ul>

***Transaction metadata*** <br/><br/>
The script will embed inside the transaction a metada file containing the minting asset's details

![image](https://github.com/tkindeke/nft_certificate/assets/108430505/59f9492f-c44a-481b-85d8-6303a1bb4ec6)


***Premint UTXO model*** <br/><br/>
In this model we can see that the minting transaction is taking as input, an UTXO (*from the store wallet*) and a minting policy script to generate two outputs.
One of the outputs is the change (value from wallet - transaction fee) that goes back to the store wallet and the other one is the minted asset that is sent to the treasury.

![image](https://github.com/tkindeke/nft_certificate/assets/108430505/502047fb-3081-4be4-a71d-72069179edfd)

***Running the premint script*** <br/><br/>
![image](https://github.com/tkindeke/nft_certificate/assets/108430505/5350484a-13bf-4157-b9d6-0fb17c47d81e)

You'll find the .hs file holding the minting policy logic under the source folder. This minting policy is parameterized, and takes as a parameter an object containing the store wallet pubkeyhash, the treasury pubkeyhash and a deadline posixtime value.
The store and treasury pubkeyhashes are used to validate signatures, while the deadline parameter helps to make sure that the minting happens before a certain time.
Under the solution folder, you should also find the nft-mint.sh shell script. This script contains the transaction contruction to trigger the mint.

Here below are the instructions to test the premint:
> **Note:**<br/>
*You should run the cardano node before testing.*
<br/><br/>
1. enter GHCi with cabal repl under the root folder
   ![image](https://github.com/tkindeke/nft_certificate/assets/108430505/e1a9e840-915a-4c3b-ad85-94533ea47e3f)

2. import Plutus.V2.Ledger.Api
3. :set -XOverloadedStrings (we need to do this because we'll be setting pubkeyhash parameters)
4. set the minting policy parameter as following -> pp = PremintParams "88cb21a61859a9272582fbc8236ac6eec0143e2d88500388416d6ca2" "7bdf13963154ece0046c97dd6ef09a26af799a9b90ea0079782d4b8f" 1687270200000 (note that the first parameter is the store pubkeyhash, followed by the treasury pubkeyhash then the deadling. this value has to be updated accordingly to the deadline you're willing to set)
5. apply the parameters to the minting policy and save the same to disk using the following command -> saveMintPolicy $ parameterizedPolicy pp
   ![image](https://github.com/tkindeke/nft_certificate/assets/108430505/b769e709-15b5-45a9-971c-22004475770d)

6. generate the policy id from the prompt terminal -> cardano-cli transaction policyid --script-file policy/mintPolicy.plutus > policy/policyID
   ![image](https://github.com/tkindeke/nft_certificate/assets/108430505/3cf62b7e-823c-458b-9e28-68a92a2d0874)

7. copy the newly generated policyid and update the same on existing metada.json
   ![image](https://github.com/tkindeke/nft_certificate/assets/108430505/d5b5d7b4-fa4e-4715-bae9-628d9b8f577e)
   ![image](https://github.com/tkindeke/nft_certificate/assets/108430505/02418191-5fff-4df2-9b1b-2d66325d0002)

8. run the nft-mint script from the prompt terminal
   ![image](https://github.com/tkindeke/nft_certificate/assets/108430505/7f641082-04cc-4592-8894-772657f365c7)
   the script is going to build a mint transaction per metadata.json files.
   you're going to be asked to enter the UTXO to be used as input of the transaction, and also for the collateral


 






