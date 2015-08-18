#!/bin/bash

echo 'Adjusting nameservers...'
# check for root
if [ `id -u` -ne '0' ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

#update the server
yum -y update


#install tomcat
yum -y install tomcat

#add configuration
echo 'JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Xmx512m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC"' > $CATALINA_BASE/bin/setenv.sh

#Install the default web apps
yum -y install tomcat-webapps

#Restart the tomcat service
systemctl restart tomcat.service
