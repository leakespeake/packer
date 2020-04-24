#!/bin/bash
echo "Installing PHP and Apache2"
sleep 30
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y php libapache2-mod-php
sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app
