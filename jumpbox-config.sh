#!/bin/bash

# format and mount attached disk for the chain data
sudo mkfs -t ext4 /dev/sdb
sudo mkdir /terradata
sudo mount -t ext4 /dev/sdb /terradata
sudo chmod 777 /terradata

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install wget liblz4-tool aria2 -y

git -C build-terra-base/ clone https://github.com/terra-project/core.git

# install docker
# reference: https://docs.docker.com/engine/install/ubuntu/
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
 	sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y