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

![image](https://github.com/tkindeke/nft_certificate/assets/108430505/6c1e6dc2-ce6a-442d-9f74-e66de1fbc8ff)


***Premint UTXO model*** <br/><br/>
In this model we can see that the minting transaction is taking as input, an UTXO (*from the store wallet*) and a minting policy script to generate two outputs.
One of the outputs is the change (value from wallet - transaction fee) that goes back to the store wallet and the other one is the minted asset that is sent to the treasury.

![image](https://github.com/tkindeke/nft_certificate/assets/108430505/cfbe84d5-9405-4f1f-a203-c36a0ec8b8ff)







