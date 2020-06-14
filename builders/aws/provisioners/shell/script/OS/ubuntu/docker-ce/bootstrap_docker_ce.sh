#!/bin/bash

# bake the selected base Ubuntu AMI with Docker CE for immediate container functionality
# upon boot, test with - sudo docker run hello-world

# uninstall older versions of docker if installed, preserving contents of /var/lib/docker/ (images, containers, volumes, networks)
sudo apt-get remove docker docker-engine docker.io

# update apt package index
sudo apt-get update
sudo apt-get -y upgrade
 
# install packages to allow apt to use a repository over HTTPS
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
 
# add dockers official gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# verify fingerprint by searching for the last 8 characters
sudo apt-key fingerprint 0EBFCD88
 
# set up the stable docker repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# update apt package index again
sudo apt-get update

# ensure you are installing docker-ce from the docker.com repository, not the default Ubuntu repo
sudo apt-cache policy docker-ce

# install docker-ce
sudo apt-get install -y docker-ce
 
# add the ubuntu user to the docker group to ensure sudo is not required to execute Docker commands on any EC2 instance provisioned from resulting AMI
sudo groupadd docker
sudo usermod -aG docker ubuntu
 
# ensure Docker starts up automatically at boot
sudo systemctl enable docker