#!/bin/bash

gcloud compute instances create jump \
	--deletion-protection \
	--shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--source-snapshot=https://compute.googleapis.com/compute/v1/projects/terra-309517/global/snapshots/terra-snapshot \
	--machine-type e2-highcpu-8 \
	--disk=name=terra-data,scope=regional

gcloud beta compute --project=terra-309517 instances create jump \
	--zone=us-central1-a \
	--machine-type=e2-highcpu-8 \
	--subnet=default \
	--network-tier=PREMIUM \
	--metadata=ssh-keys=jo:ssh-rsa\ AAAAB3NzaC1yc2EAAAADAQABAAABAQDC0wAWElRvrvY/HvgmbdS1HO/CoBhjsnfdoEnaJOMbqbDeUVyT\+4RjR1/aHeWuLz9y\+gF9LZhH2hJG\+KvAdOqeWTMASaIH0vg59/vMJQ\+EnQ1uJqP0ueIip6mLeo1cScttjcPsOACyMzZnU1i5xVPjdmzwf5SYLBx8pX55fRaGeIF70cYuihW96nM704ab2wW\+GdtOPpp\+d296tm2wYJ0nC6yvkrG39EXEQbcOfnI995PsWiENbmkxfkA9o0FRf5G78P1fHPqCVG9kst87H\+\+emf9evDLNgrCQT2dgzuKWWgUo0Wqffd7pCt842IKr2ar3LkjEv/1oXYRqCafJVIWj\ jo@jo \
	--maintenance-policy=MIGRATE \
	--service-account=1012291074262-compute@developer.gserviceaccount.com \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--image=ubuntu-1804-bionic-v20210325 \
	--image-project=ubuntu-os-cloud \
	--boot-disk-size=10GB \
	--boot-disk-kms-key=projects/terra-309517/locations/global/keyRings/jo/cryptoKeys/jo-key \
	--boot-disk-type=pd-balanced \
	--boot-disk-device-name=instance-1 \
	--create-disk=mode=rw,size=1500,type=projects/terra-309517/zones/us-central1-a/diskTypes/pd-standard,name=terradata,device-name=terradata \
	--shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--reservation-affinity=any
