LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE="--trace"
MIN_GAS="5000000aatm"
atmosd start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=$MIN_GAS --json-rpc.api eth,txpool,personal,net,debug,web3

