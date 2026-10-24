#!/bin/bash
# best practice to clean up your activities after baking a template
set -e

echo '=== STAGE 1: PURGE INSTALLER NETWORK CACHES ==='
# Clear Subiquity installer artifacts so vSphere can customize the network cleanly
rm -f /etc/netplan/00-installer-config.yaml
rm -f /etc/netplan/99-installer.cfg
rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg

echo '=== STAGE 2: APPLY VMWARE GUEST OS CUSTOMIZATION FIXES ==='
sed -i '/^\[Unit\]/a After=dbus.service' /lib/systemd/system/open-vm-tools.service
awk 'NR==11 {$0="#D /tmp 1777 root root -"} 1' /usr/lib/tmpfiles.d/tmp.conf | tee /usr/lib/tmpfiles.d/tmp.conf

echo '=== STAGE 3: DISABLE CLOUD-INIT ==='
touch /etc/cloud/cloud-init.disabled

echo '=== STAGE 4: PACKAGE MANAGER CLEANUP ==='
export DEBIAN_FRONTEND=noninteractive
apt-get -y autoremove --purge
apt-get -y clean
rm -rf /var/lib/apt/lists/*

echo '=== STAGE 5: RESET UNIQUE MACHINE IDENTIFIERS ==='
# Forces cloned VMs to generate a unique machine ID and request a unique DHCP IP
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

echo '=== STAGE 6: SANITISE LOGS AND TEMPORARY FILES ==='
find /var/log -type f -exec truncate -s 0 {} \;
rm -rf /var/tmp/*

echo '=== STAGE 7: PURGE BASH HISTORY COMPLETELY ==='
# Clears active shell history and deletes history files for all system accounts
history -c
rm -f /root/.bash_history
rm -f /home/ubuntu/.bash_history

exit 0
