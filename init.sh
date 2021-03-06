KEY="ppenter"
CHAINID="atmos_3000-1"
MONIKER="atmos-founder"
KEYRING="os"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE="--trace"
MIN_GAS="5000000aatm"

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# remove existing daemon
rm -rf ~/.atmosd*

make install

atmosd config keyring-backend $KEYRING
atmosd config chain-id $CHAINID

# if $KEY exists it should be deleted
atmosd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

# Set moniker and chain-id for Evmos (Moniker can be anything, chain-id must be an integer)
atmosd init $MONIKER --chain-id $CHAINID 

# Change parameter token denominations to aatm
cat $HOME/.atmosd/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="aatm"' > $HOME/.atmosd/config/tmp_genesis.json && mv $HOME/.atmosd/config/tmp_genesis.json $HOME/.atmosd/config/genesis.json
cat $HOME/.atmosd/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="aatm"' > $HOME/.atmosd/config/tmp_genesis.json && mv $HOME/.atmosd/config/tmp_genesis.json $HOME/.atmosd/config/genesis.json
cat $HOME/.atmosd/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="aatm"' > $HOME/.atmosd/config/tmp_genesis.json && mv $HOME/.atmosd/config/tmp_genesis.json $HOME/.atmosd/config/genesis.json
cat $HOME/.atmosd/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="aatm"' > $HOME/.atmosd/config/tmp_genesis.json && mv $HOME/.atmosd/config/tmp_genesis.json $HOME/.atmosd/config/genesis.json
cat $HOME/.atmosd/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="aatm"' > $HOME/.atmosd/config/tmp_genesis.json && mv $HOME/.atmosd/config/tmp_genesis.json $HOME/.atmosd/config/genesis.json

# increase block time (?)
cat $HOME/.atmosd/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="10"' > $HOME/.atmosd/config/tmp_genesis.json && mv $HOME/.atmosd/config/tmp_genesis.json $HOME/.atmosd/config/genesis.json

# Set gas limit in genesis
cat $HOME/.atmosd/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.atmosd/config/tmp_genesis.json && mv $HOME/.atmosd/config/tmp_genesis.json $HOME/.atmosd/config/genesis.json

# disable produce empty block
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.atmosd/config/config.toml
  else
    sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.atmosd/config/config.toml
fi

if [[ $1 == "pending" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.atmosd/config/config.toml
      sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.atmosd/config/config.toml
  else
      sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.atmosd/config/config.toml
      sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.atmosd/config/config.toml
  fi
fi

# Allocate genesis accounts (cosmos formatted addresses)
atmosd add-genesis-account $KEY 100000000000000000000000000aatm --keyring-backend $KEYRING

# Sign genesis transaction
atmosd gentx $KEY 1000000000000000000000aatm --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
atmosd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
atmosd validate-genesis

if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
# atmosd start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001aatm --json-rpc.api eth,txpool,personal,net,debug,web3 --api.enable --rpc.unsafe --rpc.laddr "tcp://0.0.0.0:26657"
