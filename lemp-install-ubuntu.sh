#!/usr/bin/env bash


# check for root
if [ `id -u` -ne '0' ]; then
  echo "This script must be run as root" >&2
  exit 1
fi


#variables
DBPASSWD=root


clear
echo
echo "*****************************************************"
echo "WARNING: DO NOT USE THIS FOR A PRODUCTION ENVIRONMENT"
echo "USE AT YOUR OWN RISK"
echo
echo "PURPOSE: INSTALL LEMP ON UBUNTU OR DEBIAN"
echo "*****************************************************"
echo

#update the package lists
echo 'Updating package lists...'
apt-get update

#run an update
echo 'Updating packages...'
apt-get install -y upgrade

#install nginx
echo 'Installing nginx...'
mkdir /usr/share/nginx/html
apt-get install -y nginx

#save the default nginx config then update it to handle php
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
echo 'server {
        listen 80;
        root /usr/share/nginx/html;
        index index.php index.html index.htm;
        server_name localhost;

        location ~ \.php$ {
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }
}' | sudo tee /etc/nginx/sites-available/default
service nginx restart

#install php and other related packages
echo 'Installing php...'
apt-get install -y php5-fpm

#configure php processor & restart
echo 'Configuring php...'
sed -i s/\;cgi\.fix_pathinfo\s*\=\s*1/cgi.fix_pathinfo\=0/ /etc/php5/fpm/php.ini
service php5-fpm restart

#create the phpinfo page
echo "
<?php phpinfo(); ?>" > /usr/share/nginx/html/index.php

# Install MySQL
echo 'Installing mysql...'
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
apt-get install -y mysql-server
# Setup db structure
mysql_install_db


# Command-Line Interpreter
apt-get install -y php5-cli

# MySQL database connections directly from PHP
apt-get install -y php5-mysql


# Install Composer
echo 'Installing composer...'
curl -s https://getcomposer.org/installer | php
# Make Composer available globally
mv composer.phar /usr/local/bin/composer


# Install PHPMyAdmin
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get install -y phpmyadmin
# Make PHPMyAdmin available as http://localhost/phpmyadmin
ln -s /usr/share/phpmyadmin /usr/share/nginx/html/phpmyadmin


echo
echo "*****************************************************"
echo "LEMP INSTALLATION COMPLETE"
echo "*****************************************************"
echo
echo
#clear
echo 'nginx installed. Version info is:'
nginx -v
echo
echo

echo 'PHP installed. Version info is:'
php -v
echo
echo

echo 'mysql installed with a root password of:'  $DBPASSWD 
echo "Version info is:"
mysql --version
echo
echo
echo "*****************************************************"
