# EOS Node Setup
This is a step-by-step guideline to build an EOS Full Node.

In case you want to build a Private EOS Blockchain for testing purposes, please refer to another guideline over here.

## Table of Contents
1. [Dependencies](#dependencies)
2. [Wallet Setup](#wallet-setup)
3. [Node Initiation](#node-initiation)
4. [Basic Usage](#basic-usage)

## Dependencies
Install [EOSIO](https://github.com/EOSIO/eos).

Install [EOSIO.CDT](https://github.com/EOSIO/eosio.cdt) (optional, required for smart contracts deployment).

## Wallet Setup 
Create a new wallet (skip this step if you already have a locally stored wallet):
```sh
cleos wallet create --to-console
```

> Creating wallet: default<br/>
Save password to use in the future to unlock this wallet.<br/>
Without password imported keys will not be retrievable.<br/>
"PW5KC8otxqtEsVUUYdy6nqPuW63v5z8Nwwg3Wtje3HP5CCNzZhjMP"

Open the wallet:
```sh
cleos wallet open
```
Unlock the wallet:
```sh
cleos wallet unlock
```
Paste the above generated password and press enter.

Generate a pair of Public Key and Private Key:
```sh
cleos create key --to-console
```

>Private key: 5JhtdjUdCEAtvsM3oxwt88UTD6uviPJQcJYG5EjVtB4pSavX2du<br/>
Public key: EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi


Import Private Key to the wallet:
```sh
cleos wallet import --private-key
```
Enter the above generated Private Key.
## Node Initiation
Clone master branch:
```sh
git clone https://github.com/tuan-tl/eos-node
cd eos-node
```
Build the directory:
```sh
./build.sh
```
Below is an example for Block Producer Node deployment:
```
1) Block Producer
Genesis Key: EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi
Producer Name: eosio
Public Key: EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi
Private Key: 5JhtdjUdCEAtvsM3oxwt88UTD6uviPJQcJYG5EjVtB4pSavX2du
HTTP Request Endpoint: default
P2P Listen Endpoint: default
P2P Peering Address: localhost:9011 localhost:9012 localhost:9013
```
Below is an example for API Full Node deployment:
```
2) API Full Node
Genesis Key: EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi
HTTP Request Endpoint: default
P2P Listen Endpoint: default
P2P Peering Address: localhost:9011 localhost:9012 localhost:9013
```
Initiate the node:
```sh
cd node
./genesis_start.sh
tail -f ./blockchain/nodeos.log
```
## Basic Usage
#### Initiate the node:

```sh
./genesis_start.sh
```
#### Stop the node:
```sh
./stop.sh
```
#### Clean blockchain data:
```sh
./clean.sh
```
#### Start the node:

```sh
./start.sh
```
#### Start the node with replaying all transactions from the genesis:
```sh
./hard_start.sh
```

#### Check sync status:
```sh
tail -f ./blockchain/nodeos.log
```

## Troubleshooting
#### Http service failed to start: Address already in use
```
error 2019-11-13T08:11:00.893 nodeos    http_plugin.cpp:545           plugin_startup       ] http service failed to start: Address already in use
error 2019-11-13T08:11:00.895 nodeos    main.cpp:134                  main                 ] Address already in use
```
Resolution:
```sh
pkill nodeos
```
