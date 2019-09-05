#!/bin/bash
. config.ini
cat > ./genesis.json << EOF
{
    "initial_timestamp": "2018-12-05T08:55:11.000",
    "initial_key": "$EOS_PUB_DEV_KEY",
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

NODEDIR="./node"
if [ ! -d $NODEDIR ]; then
  mkdir -p $NODEDIR;
fi

function generate_file {
cat > $NODEDIR/$1 << EOF
source ../config.ini
#!/bin/bash
DATADIR="./blockchain"
if [ ! -d \$DATADIR ]; then
mkdir -p \$DATADIR;
fi
nodeos \\$2
--signature-provider \$EOS_PUB_DEV_KEY=KEY:\$EOS_PRIV_DEV_KEY \\
--plugin eosio::producer_plugin \\
--plugin eosio::chain_api_plugin \\
--plugin eosio::http_plugin \\
--plugin eosio::history_api_plugin \\
--plugin eosio::history_plugin \\
--data-dir \$DATADIR"/data" \\
--blocks-dir \$DATADIR"/blocks" \\
--config-dir \$DATADIR"/config" \\
--producer-name \$PRODUCER_NAME \\
--http-server-address \$HTTP_SERVER_ADDRESS \\
--p2p-listen-endpoint \$P2P_LISTEN_ENDPOINT \\
--access-control-allow-origin=* \\
--contracts-console \\
--http-validate-host=false \\
--verbose-http-errors \\
--enable-stale-production \\
--p2p-peer-address \$P2P_PEER_ADDRESS_1 \\
--p2p-peer-address \$P2P_PEER_ADDRESS_2 \\
--p2p-peer-address \$P2P_PEER_ADDRESS_3 \\$3
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

generate_file genesis_start.sh $'\n''--genesis-json $DATADIR"/../../genesis.json" \'
generate_file start.sh 
generate_file hard_replay.sh '' $'\n''--hard-replay-blockchain \'
generate_stop_file

chmod 755 $NODEDIR/genesis_start.sh
chmod 755 $NODEDIR/start.sh
chmod 755 $NODEDIR/hard_replay.sh
chmod 755 $NODEDIR/stop.sh
chmod 755 $NODEDIR/clean.sh