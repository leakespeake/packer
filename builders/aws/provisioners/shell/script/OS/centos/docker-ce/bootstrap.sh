#!/bin/bash -ex

# Packer usage - bake the selected base CentOS 8 AMI with; 
# Docker CE for immediate container functionality - sudo docker run hello-world
# Python 3 for Ansible functionality (OpenSSH server pre-installed)

# update all packages and upgrade
echo "UPDATE AND UPGRADE"
sudo yum update -y
sudo yum upgrade -y

# install python 3
echo "INSTALL PYTHON 3"
sudo yum install python3 -y

# uninstall older versions of docker if installed, preserving contents of /var/lib/docker/ (images, containers, volumes, networks)
echo "UNINSTALL OLD DOCKER VERSIONS"
sudo yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine

# install the yum-utils package (which provides the yum-config-manager utility)
echo "INSTALL YUM-UTILS"
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# set up the stable docker repository
echo "ADD STABLE DOCKER REPOSITORY"
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# install the latest version of docker-ce and containerd
echo "INSTALL DOCKER-CE AND CONTAINERD"
sudo yum install -y docker-ce docker-ce-cli containerd.io --nobest

# add the centos user to the docker group to ensure sudo is not required to execute Docker commands on any EC2 instance provisioned from resulting AMI
echo "ADD CENTOS USER TO DOCKER GROUP"
sudo usermod -aG docker centos
 
# ensure Docker starts up automatically at boot
echo "SET DOCKER TO AUTO START AT BOOT"
sudo systemctl enable docker