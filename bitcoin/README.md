# COP5615: Distributed Operating Systems 
# Project 4.1: Implementation of Bitcoin Protocol

Team Members:
```
Sai Swetha Kondubhatla  UFID: 1172 9282
Nikhil Reddy Kortha     UFID: 7193 8560
```

## What is Working
* **Wallet**: Every user maintains a wallet and the wallet consists of user Public key, Private key, balance remaining and the transactions he sent to other users and the transactions he received from other users. These transactions are called Unspent transactions and these determine the balance left in his account. 

* **Transactions**: Every transaction has a transaction id which uniquely determines the transaction based on sender, receiver and the amount sent by the sender to receiver. Once the transaction is broadcasted to other users, the sender approves the transaction by appending a digital signature next to the transaction and every user verifies if it is a valid transaction. If in case, it isnt a valid transation then the transaction will be removed from every user's ledger. 

* **Blockchain**: A blockchian is maintained with a list of blocks. Once, tranasction is made, the transaction is appended to the current block and we maintained a condition that after every 5 transactions, a new block will be created with previous hash as the hash value of the previous block. This blockchain is mainted in every node's state. 

* **Mining**: We randomly picked 3 users as miners and these miners generate the proof of work with the mentioned difficulty for the previous completed blocks. The difficulty value determines the number of zeros in beginning of hash and the user which finishes the proof of work first, will get to append its block to every chain

## Test Cases
* **blockchain_test.exs**:
  * Add a block to the chain and validate it using valid function in BlockChain.ex for 20 nodes and 10 transactions. 
  * Insert a new block and check if its appending to the chain
  * create a block for every 5 transactions
*  **mining_test.exs**: 
    * check if the hash value has same number of zeros as teh difficlty
    * check with difficulty 1
    * check with difficulty 2
    * check with difficulty 3
    * check with difficulty 4
* **private_key.exs**:
    * Generate public key and private key for a node
    * Take a message and sign it with your private key and verify the signatiure with its message. 
    * Verify the signature with same message and it should be true. 
    * Verify the signature with different message and it should be false since it is a different message
* **transaction_test.exs**: 
    * After a transaction is made between the sender and receiver, check if the sender has the amount he wants to send to the receiver. 
    * After a Successful transaction check if the sender wallet is updated, i.e. the balance is changed and teh transaction is updated to the unspent transactions list. 
    * Also check if the receiver balance is updated with the amount the sender sent and also check receiver's unspent transactions
* **wallet_test.exs**: 
    * After a coinbase transaction, check if the transaction list is upadted with the coinbase transaction
    * Also verify if the wallet is updated with a initial balance of 100
    
## How to run
```
mix test test/<sample_file>.exs
```
 