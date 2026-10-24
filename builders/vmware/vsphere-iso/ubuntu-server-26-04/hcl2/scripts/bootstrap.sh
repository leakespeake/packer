#!/bin/bash -ex

# Bake this base Ubuntu Server 26.04 Packer template with:
# - docker-ce for immediate container functionality
# - python 3 and openssh-server for Ansible functionality (verified pre-installed via base ISO manifest)

echo '=== BAKE IN PASSWORDLESS SUDO FOR UBUNTU USER ==='
# Append passwordless privileges to the user profile natively inside the target filesystem
echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu
chmod 440 /etc/sudoers.d/ubuntu

echo '=== UPDATE AND UPGRADE ==='
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

echo '=== CHECK PYTHON 3 VERSION ==='
python3 -V
 
echo '=== INSTALL BASE PREREQUISITES ===' 
apt-get install -y ca-certificates curl

echo '=== ADD DOCKER GPG KEY ==='
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo '=== ADD STABLE DOCKER REPOSITORY ==='
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo '=== UPDATE PACKAGE INDEX ==='
apt-get update

echo '=== ENSURE USE OF DOCKER REPO FOR DOCKER-CE INSTALL ==='
apt-cache policy docker-ce

echo '=== INSTALL DOCKER-CE ==='
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
 
echo '=== ADD UBUNTU USER TO DOCKER GROUP ===' 
usermod -aG docker ubuntu

echo '=== CONFIGURE DOCKER REMOTE API ==='
mkdir -p /etc/systemd/system/docker.service.d
# Use post-deployment Ansible playbook to generate TLS certs and secure Docker Remote API
mkdir -p /etc/docker/certs

tee /etc/systemd/system/docker.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
EOF

echo '=== SET DOCKER TO AUTO START AT BOOT ==='
systemctl daemon-reload
systemctl restart docker.service
systemctl enable docker
