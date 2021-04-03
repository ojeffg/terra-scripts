#!/bin/bash

CLUSTERNAME=terra
CLUSTERVERSION=pin
MACHINETYPE=n1-standard-2

# create new cluster
gcloud container clusters create \
	--machine-type $MACHINETYPE \
	--cluster-version $CLUSTERVERSION \
	--zone us-east1-a  \
	--node-locations us-central1-a,us-central1-b \
	--num-nodes 2 \
	--enabled-master-authorized-networks \
	--master-authorized-networks 136.56.37.7/32 \
	--master-ipv4-cidr 172.16.0.0/16 \
	--create-subnetwork name=$CLUSTERNAME-subnet \
	--enable-ip-alias \
	--enable-private-nodes \
	$CLUSTERNAME


# security

## auditing on

