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


# Install PHPMyAdmin
echo "Installing PHPMyAdmin"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get install -y phpmyadmin
# Make PHPMyAdmin available as http://localhost/phpmyadmin
ln -s /usr/share/phpmyadmin /usr/share/nginx/html/phpmyadmin

clear

echo "********************************************************"
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
apt-cache show mysql-server | grep Version
echo
echo
echo "********************************************************"
echo "YATA!"
