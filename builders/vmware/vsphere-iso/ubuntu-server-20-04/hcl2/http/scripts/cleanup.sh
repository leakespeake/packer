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

exit