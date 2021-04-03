#!/bin/bash

gcloud compute instances create jump \
	--deletion-protection \
	--shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--source-snapshot=https://compute.googleapis.com/compute/v1/projects/terra-309517/global/snapshots/terra-snapshot \
	--machine-type e2-highcpu-8 \
	--disk=name=terra-data,scope=regional