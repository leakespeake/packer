#!/bin/sh
# best practice to clean up your activities after baking an AMI
 
set -e
 
echo 'CLEANING UP AFTER BOOTSTRAPPING...'
sudo yum clean all
sudo rm -rf /tmp/*
cat /dev/null > ~/.bash_history
exit