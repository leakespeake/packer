#!/bin/sh
# best practice to clean up your activities after baking an AMI
 
set -e
 
echo 'CLEANING UP AFTER BOOTSTRAPPING...'
sudo apt-get -y autoremove
sudo apt-get -y clean
sudo rm -rf /var/lib/apt/lists/* /tmp/*
cat /dev/null > ~/.bash_history
exit