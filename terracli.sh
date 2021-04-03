
#!/bin/bash

# this script can run once terrad is up and running in order to configure our local terracli and initialize validator


[ -z $MONIKER ] && echo "[ERROR] MONIKER is required.  Exiting." && exit 1
[ -z $NETWORK ] && echo "[ERROR] NETWORK is required.  Exiting." && exit 1
[ -z $WALLET ] && echo "[ERROR] WALLET is required.  Exiting." && exit 1

echo; echo "[INFO] Configuring chain"
terracli config chain-id $NETWORK

echo; echo "[INFO] Configuring node"
terracli config node tcp://localhost:26657

echo; echo "[INFO] Configuring trust node to true"
terracli config trust-node true

echo; echo "[INFO] Recovering keys for account:  $MONIKER"
cat private/wallets/${WALLET}/mn | terracli keys add $WALLET --recover 

echo; echo "[INFO] Retrieving tendermint validator public key:"
VALIDATOR_PUB_KEY=$(docker exec -it terrad -- terrad tendermint show-validator)
echo -e "\t$VALIDATOR_PUB_KEY"

terracli tx staking create-validator \
	--pubkey "${VALIDATOR_PUB_KEY}" \
	--amount "1000000uluna" \
	--from "${WALLET}" \
	--commission-rate="0.1" \
	--commission-max-rate="0.2" \
	--commission-max-change-rate=".05" \
	--min-self-delegation "1" \
	--moniker "${MONIKER}" \
	--chain-id "${NETWORK}" \
	--gas-auto \
	--node "tcp://localhost:26657" \
	--gas-prices="1.5uluna" \
	--gas-adjustment=1.4