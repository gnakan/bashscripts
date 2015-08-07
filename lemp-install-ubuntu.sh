#!/usr/bin/env bash

#variables
DBHOST=localhost
DBNAME=db1
DBUSER=dbuser
DBPASSWD=dbpassword


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



# Install MySQL
echo 'Installing mysql...'
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
apt-get install -y mysql-server-5.5
# Setup db structure
mysql_install_db
# Secure Installation as defined via mysql_secure_installation
mysql -uroot -p$DBPASSWD -e "DROP DATABASE test"
mysql -uroot -p$DBPASSWD -e "DELETE FROM mysql.user WHERE User='root' AND NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -uroot -p$DBPASSWD -e "DELETE FROM mysql.user WHERE User=''"
mysql -uroot -p$DBPASSWD -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
mysql -uroot -p$DBPASSWD -e "FLUSH PRIVILEGES"

# Install php/myql stuff
apt-get install -y php5-mysql


# Install Composer
echo 'Installing composer...'
curl -s https://getcomposer.org/installer | php
# Make Composer available globally
mv composer.phar /usr/local/bin/composer


# Install PHPMyAdmin NOT ADVISABLE FOR PRODUCTION
echo "Installing PHPMyAdmin"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get install -y phpmyadmin
# Make PHPMyAdmin available as http://localhost/phpmyadmin
ln -s /usr/share/phpmyadmin /usr/share/nginx/html/phpmyadmin

#clear
echo "nginx, php, and mysql are now installed!"