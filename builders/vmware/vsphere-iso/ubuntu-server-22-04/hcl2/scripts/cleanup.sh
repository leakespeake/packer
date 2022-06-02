#!/bin/sh
# best practice to clean up your activities after baking a template
 
set -e
 
echo 'APT CLEANUP'
sudo apt-get -y autoremove
sudo apt-get -y clean
sudo rm -rf /var/lib/apt/lists/*

echo 'TMP CLEANUP'
sudo rm -rf /tmp/*

echo 'BASH HISTORY CLEANUP'
cat /dev/null > ~/.bash_history

# vmware guest os customization with cloud-init fails on the network configuration for ubuntu 20.04.x live server and later - fixes below;
echo 'FIX VMWARE GUEST OS CUSTOMIZATION WITH SUBIQUITY'
sudo sed -i '/^\[Unit\]/a After=dbus.service' /lib/systemd/system/open-vm-tools.service
sudo awk 'NR==11 {$0="#D /tmp 1777 root root -"} 1' /usr/lib/tmpfiles.d/tmp.conf | sudo tee /usr/lib/tmpfiles.d/tmp.conf

echo 'DISABLE CLOUD INIT'
sudo touch /etc/cloud/cloud-init.disabled

exit