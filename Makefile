
NETWORK=tequila-0004
SYNCURL=https://get.quicksync.io
MONIKER=RnodeC
LC_MONIKER=$(shell echo ${MONIKER} | tr '[:upper:]' '[:lower:]')
WALLET=testwallet
VERSION=0.4.5
TERRABASE_CTR=terrabase
DATADIR=/terradata
CHAINFILENAME=tequila-4-default.20210401.0940

# built vars
MYTERRABASE_CTR=myterra-base-${LC_MONIKER}-${NETWORK}
MYTERRAD_CTR=myterra-d-${LC_MONIKER}-${NETWORK}
MYFEEDER_CTR=myterra-feeder-${LC_MONIKER}-${NETWORK}
MYLCD_CTR=myterra-lcd-${LC_MONIKER}-${NETWORK}

#reference: https://terra.quicksync.io/
get-chain:
	echo; echo "[INFO] Downloading ${NETWORK} chain ${CHAINFILENAME}.tar.lz4 to ${DATADIR}"
	aria2c -x5 ${SYNCURL}/${CHAINFILENAME}.tar.lz4 -d ${DATADIR}
	wget https://raw.githubusercontent.com/chainlayer/quicksync-playbooks/master/roles/quicksync/files/checksum.sh
	wget https://get.quicksync.io/${CHAINFILENAME}.tar.lz4.checksum
	curl -s https://lcd.terra.dev/txs/`curl -s https://get.quicksync.io/${CHAINFILENAME}.tar.lz4.hash`|jq -r '.tx.value.memo'|sha512sum -c
	./checksum.sh ${DATADIR}/${CHAINFILENAME}.tar.lz4
	lz4 -d ${DATADIR}/${CHAINFILENAME}.tar.lz4 ${DATADIR}/${CHAINFILENAME}.tar
	echo "[INFO] Removing ${DATADIR}/${CHAINFILENAME}.tar.lz4"
	rm -f ${DATADIR}/${CHAINFILENAME}.tar.lz4
	tar xf ${DATADIR}/${CHAINFILENAME}.tar -C ${DATADIR}/${NETWORK}
	echo "[INFO] Removing ${DATADIR}/${CHAINFILENAME}.tar"
	rm -f ${DATADIR}/${CHAINFILENAME}.tar
	chown -R 1000:1000 terradata/${NETWORK}

#start the container associated with this network/moniker/version and run terrad node
run-terrad: 
	echo; echo "[INFO] Starting ${MYTERRA_CTR} in terrad mode"; echo
	docker run -it --rm \
		-v ${DATADIR}/${NETWORK}/data:/terradata \
		-p 26656-26658:26656-26658 \
		--hostname localterrad \
		--name terrad \
		${MYTERRAD_CTR}:${VERSION} 

#start the container associated with this network/moniker/version and drop into a shell
run-terrad-shell: 
	echo; echo "[INFO] Starting ${MYTERRAD_CTR} in shell mode"; echo
	docker run -it --rm \
		-v ${DATADIR}/${NETWORK}/data:/terradata  \
		-p 26656-26658:26656-26658 \
		--hostname localterrad \
		--name terrad \
		--entrypoint "/bin/sh" \
		${MYTERRAD_CTR}:${VERSION} 


run-terra-lcd: 
	echo; echo "[INFO] Starting ${MYLCD_CTR} in terra-lcd mode"; echo
	docker run -it --rm \
		-p 1317:1317 \
		--hostname locallcd \
		--name lcd \
		${MYLCD_CTR}:${VERSION}

run-feeder: 
	echo; echo "[INFO] Starting ${MYFEEDER_CTR} in terra-lcd mode"; echo
	docker run -itd --rm \
		--hostname localfeeder \
		--name feeder \
		${MYFEEDER_CTR}:${VERSION} 


# build the base terra ctr from upstream + layer on our base config specific to target network & moniker
update-base-terra-ctr:
	echo; echo "[INFO] Building new base ${BASE_CTR} container with tag: ${VERSION}"
	echo; echo "[INFO] Pulling latest version of upstream git master"
	git -C build-terra-base/core/ pull
	echo; echo "[INFO] Pulling latest version of alpine:3.12"
	docker pull alpine:3.12
	docker build -t ${TERRABASE_CTR}:${VERSION} build-terra-base/core/
	echo; echo "[INFO] Building new base ${MYTERRABASE_CTR} container with tag: ${VERSION}"
	docker build -t ${MYTERRABASE_CTR}:${VERSION} build-terra-base/ \
		--build-arg MONIKER=${MONIKER} \
		--build-arg NETWORK=${NETWORK} \
		--build-arg BASE_CTR=${TERRABASE_CTR} \
		--build-arg VERSION=${VERSION} 

# build dedicated terrad ctr from base
update-myterrad-ctr:
	echo; echo "[INFO] Updating ${MYTERRAD_CTR} to version ${VERSION}"
	echo; echo "[INFO] This is building from base ${MYTERRABASE_CTR}:${VERSION}"
	docker build -t ${MYTERRAD_CTR}:${VERSION} build-terra-d \
		--build-arg MONIKER=${MONIKER} \
		--build-arg NETWORK=${NETWORK} \
		--build-arg BASE_CTR=${MYTERRABASE_CTR} \
		--build-arg VERSION=${VERSION} 

# build dedicated lcd ctr from base
update-mylcd-ctr:
	echo; echo "[INFO] Updating ${MYLCD_CTR} to version ${VERSION}"
	echo; echo "[INFO] This is building from base ${MYTERRABASE_CTR}:${VERSION}"
	docker build -t ${MYLCD_CTR}:${VERSION} build-terra-lcd \
		--build-arg MONIKER=${MONIKER} \
		--build-arg NETWORK=${NETWORK} \
		--build-arg BASE_CTR=${MYTERRABASE_CTR} \
		--build-arg VERSION=${VERSION} 

# build dedicated feeder ctr from base
update-myfeeder-ctr:
	echo; echo "[INFO] Updating ${MYFEEDER_CTR} to version ${VERSION}"
	docker build -t ${MYFEEDER_CTR}:${VERSION} build-terra-feeder \
		--build-arg MONIKER=${MONIKER} \
		--build-arg NETWORK=${NETWORK} \
		--build-arg VERSION=${VERSION} 

build-all: 	update-base-terra-ctr update-myterrad-ctr update-mylcd-ctr
build: 		update-myterrad-ctr update-mylcd-ctr