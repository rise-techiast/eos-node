# EOS Node Setup
This is a step-by-step guideline to build an EOS Full Node.

In case you want to build a Private EOS Blockchain for testing purposes, please refer to another guideline over here.

## Table of Contents
1. [Dependencies](#dependencies)
2. [Wallet Setup](#wallet-setup)
3. [Node Initiation](#node-initiation)
4. [Basic Usage](#basic-usage)

## Dependencies
Install [EOSIO](https://github.com/EOSIO/eos) pre-compiled binaries.

Install [EOSIO.CDT](https://github.com/EOSIO/eosio.cdt) binaries (for building smart contracts).

## Wallet Setup 
Create a new wallet (skip this step if you already have a locally stored wallet):
```sh
cleos wallet create --to-console
```

> Creating wallet: default

> Save password to use in the future to unlock this wallet.

> Without password imported keys will not be retrievable.
> "PW5KC8otxqtEsVUUYdy6nqPuW63v5z8Nwwg3Wtje3HP5CCNzZhjMP"

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

```
Private key: 5JhtdjUdCEAtvsM3oxwt88UTD6uviPJQcJYG5EjVtB4pSavX2du
Public key: EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi
```

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
Change ```config.ini``` using the above generated keys (for `EOS_GENESIS_KEY` you need to get from genesis node)
```ini
EOS_GENESIS_KEY=$PUB_KEY_OF_GENESIS_NODE
EOS_PUB_KEY=EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi
EOS_PRIV_KEY=5JhtdjUdCEAtvsM3oxwt88UTD6uviPJQcJYG5EjVtB4pSavX2du
```
Build the package:
```sh
./build.sh
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