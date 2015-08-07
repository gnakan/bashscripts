#!/usr/bin/env bash


#update the package lists
apt-get update

#run an update
apt-get install -y upgrade

#install nginx
apt-get install -y nginx

#install php
apt-get install -y php5-fpm

#configure php processor & restart
sed -i s/\;cgi\.fix_pathinfo\s*\=\s*1/cgi.fix_pathinfo\=0/ /etc/php5/fpm/php.ini
service php5-fpm restart

#create the phpinfo page
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php