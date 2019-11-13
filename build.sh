#!/bin/bash
. config.ini
NODEDIR="./node"

function generate_genesis {
cat > ./genesis.json << EOF
{
    "initial_timestamp": "2018-12-05T08:55:11.000",
    "initial_key": "$EOS_GENESIS_KEY",
    "initial_configuration": {
      "max_block_net_usage": 1048576,
      "target_block_net_usage_pct": 1000,
      "max_transaction_net_usage": 524288,
      "base_per_transaction_net_usage": 12,
      "net_usage_leeway": 500,
      "context_free_discount_net_usage_num": 20,
      "context_free_discount_net_usage_den": 100,
      "max_block_cpu_usage": 100000,
      "target_block_cpu_usage_pct": 500,
      "max_transaction_cpu_usage": 50000,
      "min_transaction_cpu_usage": 100,
      "max_transaction_lifetime": 3600,
      "deferred_trx_expiration_window": 600,
      "max_transaction_delay": 3888000,
      "max_inline_action_size": 4096,
      "max_inline_action_depth": 4,
      "max_authority_depth": 6
    },
    "initial_chain_id": "0000000000000000000000000000000000000000000000000000000000000000"
}
EOF
}

function generate_file {
cat > $NODEDIR/$1 << EOF
source ../config.ini
#!/bin/bash

for i in \$P2P_PEER_ADDRESSES ; do
    P2P_PEER_ADDRESS_LIST="\$P2P_PEER_ADDRESS_LIST""--p2p-peer-address "\$i" \\\"$'\n'
done

DATADIR="./blockchain"
if [ ! -d \$DATADIR ]; then
mkdir -p \$DATADIR;
fi
nodeos \\$2$3
--plugin eosio::chain_api_plugin \\
--plugin eosio::http_plugin \\
--plugin eosio::history_api_plugin \\
--plugin eosio::history_plugin \\
--data-dir \$DATADIR"/data" \\
--blocks-dir \$DATADIR"/blocks" \\
--config-dir \$DATADIR"/config" \\
--http-server-address \$HTTP_SERVER_ADDRESS \\
--p2p-listen-endpoint \$P2P_LISTEN_ENDPOINT \\
--access-control-allow-origin=* \\
--contracts-console \\
--http-validate-host=false \\
--verbose-http-errors \\
--enable-stale-production \\$4
\$P2P_PEER_ADDRESS_LIST
>> \$DATADIR"/nodeos.log" 2>&1 & \\
echo \$! > \$DATADIR"/eosd.pid"
EOF
}

function generate_stop_file {
cat > $NODEDIR/stop.sh << EOF
#!/bin/bash
DATADIR="./blockchain/"
if [ -f \$DATADIR"/eosd.pid" ]; then
pid=\`cat \$DATADIR"/eosd.pid"\`
echo \$pid
kill \$pid
rm -r \$DATADIR"/eosd.pid"
echo -ne "Stoping Node"
while true; do
[ ! -d "/proc/\$pid/fd" ] && break
echo -ne "."
sleep 1
done
echo -ne "\rNode Stopped. \n"
fi
EOF

cat > $NODEDIR/clean.sh << EOF
#!/bin/bash
rm -fr blockchain
ls -al
EOF
}

function change_mod_files {
chmod 755 $NODEDIR/genesis_start.sh
chmod 755 $NODEDIR/start.sh
chmod 755 $NODEDIR/hard_replay.sh
chmod 755 $NODEDIR/stop.sh
chmod 755 $NODEDIR/clean.sh
}

function generate_config {

P2P_PEER_ADDRESS_STORE=""

for i in $7 ; do
    P2P_PEER_ADDRESS_STORE="$P2P_PEER_ADDRESS_STORE""P2P_PEER_ADDRESS="$i$'\n'
done

cat > ./config.ini << EOF
EOS_GENESIS_KEY=$1
EOS_PUB_KEY=$2
EOS_PRIV_KEY=$3
PRODUCER_NAME=$4
HTTP_SERVER_ADDRESS=$5
P2P_LISTEN_ENDPOINT=$6
P2P_PEER_ADDRESSES=$7
EOF
}

BP_NODE_OPTION="Block Producer"
API_FULLNODE_OPTION="API Full Node"
CANEL_OPTION="Cancel"
NODEDIR="./bp-node"
GENESIS_SCRIPT=$'\n''--genesis-json $DATADIR"/../../genesis.json" \'
BP_SCRIPT=$'\n''--signature-provider $EOS_PUB_KEY=KEY:$EOS_PRIV_KEY \'$'\n''--producer-name $PRODUCER_NAME \'$'\n''--plugin eosio::producer_plugin \'
HARD_REPLAY_SCRIPT=$'\n''--hard-replay-blockchain \'
DEFAULT_HTTP_SERVER_ADDRESS="0.0.0.0:8888"
DEFAULT_P2P_LISTEN_ENDPOINT="0.0.0.0:9010"

echo "Which node type do you want to setup?"
select yn in "$BP_NODE_OPTION" "$API_FULLNODE_OPTION" "$CANEL_OPTION"; do
    case $yn in
        $BP_NODE_OPTION )

read -p "Enter Genesis Key: " EOS_GENESIS_KEY
read -p "Enter Producer Name: " PRODUCER_NAME
read -p "Enter Public Key: " EOS_PUB_KEY
read -p "Enter Private Key: " EOS_PRIV_KEY
read -p "Enter HTTP Request Endpoint (leave empty for default): " HTTP_SERVER_ADDRESS
if [ -z $HTTP_SERVER_ADDRESS ]; then HTTP_SERVER_ADDRESS=$DEFAULT_HTTP_SERVER_ADDRESS; fi
read -p "Enter P2P Listen Endpoint (leave empty for default): " P2P_LISTEN_ENDPOINT
if [ -z $P2P_LISTEN_ENDPOINT ]; then P2P_LISTEN_ENDPOINT=$DEFAULT_P2P_LISTEN_ENDPOINT; fi
read -p "Enter P2P Peering Address (separate by \" \" for many options): " P2P_PEER_ADDRESS

if [ ! -d $NODEDIR ]; then
  mkdir -p $NODEDIR;
fi

generate_file genesis_start.sh "$GENESIS_SCRIPT" "$BP_SCRIPT"
generate_file start.sh "" "$BP_SCRIPT"
generate_file hard_replay.sh "" "$BP_SCRIPT" "$HARD_REPLAY_SCRIPT"
generate_stop_file
change_mod_files
generate_config "$EOS_GENESIS_KEY" "$EOS_PUB_KEY" "$EOS_PRIV_KEY" "$PRODUCER_NAME" "$HTTP_SERVER_ADDRESS" "$P2P_LISTEN_ENDPOINT" "$P2P_PEER_ADDRESS"

break;;

        $API_FULLNODE_OPTION ) 

read -p "Enter Genesis Key: " EOS_GENESIS_KEY
read -p "Enter HTTP Request Endpoint (leave empty for default): " HTTP_SERVER_ADDRESS
if [ -z $HTTP_SERVER_ADDRESS ]; then HTTP_SERVER_ADDRESS=$DEFAULT_HTTP_SERVER_ADDRESS; fi
read -p "Enter P2P Listen Endpoint (leave empty for default): " P2P_LISTEN_ENDPOINT
if [ -z $P2P_LISTEN_ENDPOINT ]; then P2P_LISTEN_ENDPOINT=$DEFAULT_P2P_LISTEN_ENDPOINT; fi
read -p "Enter P2P Peering Address (separate by \" \" for many options): " P2P_PEER_ADDRESS

if [ ! -d $NODEDIR ]; then
  mkdir -p $NODEDIR;
fi

generate_file genesis_start.sh "$GENESIS_SCRIPT"
generate_file start.sh "" 
generate_file hard_replay.sh "" "" "$HARD_REPLAY_SCRIPT"
generate_stop_file
change_mod_files
generate_config

break;;

        $CANEL_OPTION ) exit;;
    esac
done