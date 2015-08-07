#!/usr/bin/env bash

clear

#update the package lists
echo 'Updating package lists...'
apt-get update

#run an update
echo 'Updating packages...'
apt-get install -y upgrade

#install nginx
echo 'Installing nginx...'
apt-get install -y nginx

#install php
echo 'Installing php...'
apt-get install -y php5-fpm

#install php cli
apt-get install -y php5-cli

#install php cli
apt-get install -y php5-pear

#configure php processor & restart
echo 'Configuring php...'
sed -i s/\;cgi\.fix_pathinfo\s*\=\s*1/cgi.fix_pathinfo\=0/ /etc/php5/fpm/php.ini
service php5-fpm restart

#create the phpinfo page
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php


clear
echo "nginx, php, and mysql are now installed!"