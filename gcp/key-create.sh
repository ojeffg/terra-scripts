#!/bin/bash


#create keyring first
gcloud kms keyrings create jo \
	--location global

#create a key
gcloud kms keys create jo-key \
	--location global \
	--keyring jo -\
	--purpose encryption

#view keys in this keyring
gcloud kms keys list \
	--location global \
	--keyring jo


# if you want to use this key to encrypt files locally then you can use:  https://github.com/mozilla/sops
# install sops... https://github.com/mozilla/sops/releases
#enable the local credentials format for sops to use
#gcloud auth application-default login

#and now encrypt a file...
#sops --encrypt --gcp-kms projects/my-project/locations/global/keyRings/sops/cryptoKeys/sops-key test.yaml > test.enc.yaml


#upload a file as a secret
gcloud secrets create nodekey \
	--data-file=key.json \
    --replication-policy-file=@kmsprotection.json

#where kmsprotectionjson:
#{
#  "automatic": {
#    "customerManagedEncryption": {
#    	"kmsKeyName": "projects/terra-309517/locations/global/keyRings/jo/cryptoKeys/jo-key"
#    }
#  }
#}