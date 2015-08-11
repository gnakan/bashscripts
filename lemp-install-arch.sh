#!/bin/bash


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
echo "PURPOSE: INSTALL LEMP ON ARCH LINUX"
echo "*****************************************************"
echo

#update the package lists
echo 'Updating...'
pacman -Syu


# Install MySQL
pacman -S mysql --noconfirm
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl start mysqld

#set pw
mysql_secure_installation

#restart mysql
systemctl restart mysqld



#install nginx
echo 'Installing nginx...'
pacman install -S nginx

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

systemctl start nginx

#install php and other related packages
echo 'Installing php...'
pacman -S php-fpm --noconfirm

#configure php processor & restart
echo 'Configuring php...'
sed -i 's/;extension=mysql.so/extension=mysql\.so/g' /etc/php/php.ini
systemctl start php-fpm

#create the phpinfo page
echo "
<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php

systemctl restart nginx



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

echo 'mysql installed' 
echo "Version info is:"
mysql --version
echo
echo
echo "*****************************************************"
