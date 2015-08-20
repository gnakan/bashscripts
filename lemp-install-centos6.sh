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
echo "PURPOSE: INSTALL LEMP ON CENTOS 6"
echo "*****************************************************"
echo

#update epel repository
echo 'Updating...'
yum -y install epel-release

echo 'Installing mysql...'
#stop mysql just in case it was already installed
/etc/init.d/mysqld stop 

# Install MySQL
yum -y install mysql-server
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
/etc/init.d/mysqld start

#secure mysql


#restart mysql
mysqladmin -u root password "$DBPASSWD"
mysql -u root -p"$DBPASSWD" -e "UPDATE mysql.user SET Password=PASSWORD('$DBPASSWD') WHERE User='root'"
mysql -u root -p"$DBPASSWD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DBPASSWD" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DBPASSWD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DBPASSWD" -e "FLUSH PRIVILEGES"


#install nginx
echo 'Installing nginx...'
yum -y install nginx

echo 'Configuring nginx'
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
            root /usr/share/nginx/html;
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

#create the phpinfo page
echo "<html><h2>No Denying The Hawaiian</h2><a href='info.php'>View PHP Info</a></html>" > /urs/share/nginx/html/index.html

systemctl start nginx

#install php and other related packages
echo 'Installing php...'
yum -y install php-fpm php-mysql

#configure php processor & restart
echo 'Configuring php...'
sed -i s/\;cgi\.fix_pathinfo\s*\=\s*1/cgi.fix_pathinfo\=0/ /etc/php5/fpm/php.ini
service php-fpm restart

#create the phpinfo page
echo "<?php phpinfo(); ?>" > /srv/http/info.php

service nginx restart



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
php-fpm -v
echo
echo

echo 'mysql installed' 
echo "Version info is:"
mysql --version
echo
echo
echo "*****************************************************"
