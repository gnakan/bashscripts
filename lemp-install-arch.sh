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


systemctl stop mysqld

# Install MySQL
pacman -S mysql --noconfirm
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl start mysqld

#secure mysql


#restart mysql
#systemctl restart mysqld
mysqladmin -u root password "$DBPASSWD"
mysql -u root -p"$DBPASSWD" -e "UPDATE mysql.user SET Password=PASSWORD('$DBPASSWD') WHERE User='root'"
mysql -u root -p"$DBPASSWD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DBPASSWD" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DBPASSWD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DBPASSWD" -e "FLUSH PRIVILEGES"


#install nginx
echo 'Installing nginx...'
pacman -S nginx --noconfirm

#save the default nginx config then update it to handle php
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
echo '
#user html;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;


    server {
            listen 80;
            root /srv/http;
            index index.php index.html index.htm;
            server_name localhost;

            location ~ \.php$ {
                    fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
                    fastcgi_index index.php;
                    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                    include /etc/nginx/fastcgi_params;
                    #include fastcgi.conf;
            }
    }

}' | sudo tee /etc/nginx/nginx.conf

systemctl start nginx

#install php and other related packages
echo 'Installing php...'
pacman -S php-fpm --noconfirm

#configure php processor & restart
echo 'Configuring php...'
sed -i 's/;extension=mysql.so/extension=mysql\.so/g' /etc/php/php.ini
systemctl start php-fpm
systemctl enable php-fpm

#create the phpinfo page
echo "<?php phpinfo(); ?>" > /srv/http/info.php

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
