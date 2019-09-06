# EOS Node Setup

## Prerequisites
Install [EOSIO](https://github.com/EOSIO/eos) pre-compiled binaries.

Install [EOSIO.CDT](https://github.com/EOSIO/eosio.cdt) binaries.

## Setup wallet
Create a new wallet:
```sh
cleos wallet create --to-console
```

```
Creating wallet: default
Save password to use in the future to unlock this wallet.
Without password imported keys will not be retrievable.
"PW5KC8otxqtEsVUUYdy6nqPuW63v5z8Nwwg3Wtje3HP5CCNzZhjMP"
```
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
## Create, start and configure the Genesis node
### Create the genesis node
Clone master branch:
```sh
git clone https://github.com/tuan-tl/eos-node
cd eos-node
```
Change ```config.ini``` using the above generated keys:
```ini
EOS_INITIAL_KEY=EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi
EOS_PUB_KEY=EOS6nSXgwnwge4rHrwmixycjFPC8AayjcRXTv8R3SVEgtfw8woYQi
EOS_PRIV_KEY=5JhtdjUdCEAtvsM3oxwt88UTD6uviPJQcJYG5EjVtB4pSavX2du
```
Build the package:
```sh
./build.sh
```

### Start the genesis node
Start a genesis node by executing `genesis_start.sh`
```sh
cd node
./genesis_start.sh
```
Inspect `nodeos.log` file to see block producing status
```sh
tail -f ./blockchain/nodeos.log
```
### Create system accounts
Here is a list of system accounts to be generated:
```
eosio.bpay
eosio.msig
eosio.names
eosio.ram
eosio.ramfee
eosio.saving
eosio.stake
eosio.token
eosio.vpay
eosio.rex
```
Create keys for ```eosio.bpay``` account:
```sh
cleos create key --to-console
```

Import generated Private Key to the wallet:
```sh
cleos wallet import --private-key
```

Create ```eosio.bpay``` account:
```sh
cleos create account eosio eosio.bpay EOS84BLRbGbFahNJEpnnJHYCoW9QPbQEk2iHsHGGS6qcVUq9HhutG
```
Repeat the above steps to the rest accounts.
### Build eosio.contracts
Clone the repository:
```sh
cd ~
git clone https://github.com/EOSIO/eosio.contracts
cd ./eosio.contracts/
./build.sh
```
Install the ```eosio.token``` contract:
```sh
cleos set contract eosio.token $CONTRACTS_DIRECTORY/eosio.contracts/build/contracts/eosio.token/
```
Install the ```eosio.msig``` contract
```sh
cleos set contract eosio.msig $CONTRACTS_DIRECTORY/eosio.contracts/build/contracts/eosio.msig/
```
### Create and allocate the SYS currency
Create the SYS currency with a maximum value of 10 billion tokens. Then issue one billion tokens. Replace SYS with your specific currency designation.

Create SYS currency:
```sh
cleos push action eosio.token create '[ "eosio", "10000000000.0000 SYS" ]' -p eosio.token@active
```
Allocate SYS currency to ```eosio``` account:
```sh
cleos push action eosio.token issue '[ "eosio", "1000000000.0000 SYS", "memo" ]' -p eosio@active
```
### Activate ```eosio.system``` contract
```sh
cleos set contract eosio.token $CONTRACTS_DIRECTORY/eosio.contracts/build/contracts/eosio.system/
```

## Transition from single genesis producer to multiple producers

Make ```eosio.msig``` a privileged account:
```sh
cleos push action eosio setpriv '["eosio.msig", 1]' -p eosio@active
```
Initialize system account:
```sh
cleos push action eosio init '["0", "4,SYS"]' -p eosio@active
```

## Troubleshooting