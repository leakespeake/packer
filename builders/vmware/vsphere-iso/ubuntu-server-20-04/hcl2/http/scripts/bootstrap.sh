#!/bin/bash -ex

# bake this base Ubuntu 20.04.2-live-server packer template with; 
# docker-ce for immediate container functionality - sudo docker run hello-world
# python 3.8 pre-installed and openssh-server installed via subiquity (for ansible functionality)

# update apt package index
echo "UPDATE AND UPGRADE"
sudo apt-get update
sudo apt-get -y upgrade

# check python 3 version
echo "CHECK PYTHON 3 VERSION"
python3 -V
 
# install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common
 
# add dockers official gpg key
echo "ADD DOCKER GPG KEY"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# verify fingerprint by searching for the last 8 characters
echo "VERIFY FINGERPRINT"
sudo apt-key fingerprint 0EBFCD88
 
# set up the stable docker repository
echo "ADD STABLE DOCKER REPOSITORY"
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# update apt package index again
echo "UPDATE PACKAGE INDEX"
sudo apt-get update

# ensure you are installing docker-ce from the docker.com repository, not the default Ubuntu repo
echo "ENSURE USE OF DOCKER REPO FOR DOCKER-CE INSTALL"
sudo apt-cache policy docker-ce

# install docker-ce
echo "INSTALL DOCKER-CE"
sudo apt-get install -y docker-ce
 
# add the ubuntu user to the docker group to ensure sudo is not required to execute Docker commands on any vm provisioned from resulting template
echo "ADD UBUNTU USER TO DOCKER GROUP"
sudo usermod -aG docker ubuntu
 
# ensure Docker starts up automatically at boot
echo "SET DOCKER TO AUTO START AT BOOT"
sudo systemctl enable docker