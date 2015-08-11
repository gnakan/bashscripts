#!/usr/bin/env bash

echo 'Adjusting nameservers...'
# check for root
if [ `id -u` -ne '0' ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

cp /etc/resolv.conf /etc/resolv.conf.BAK


echo '
	nameserver	208.109.188.8
	nameserver	208.109.188.8
' | sudo tee /etc/resolv.conf


echo 'Nameservers adjusted.'