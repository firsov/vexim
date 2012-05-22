#!/usr/local/bin/bash
if [ "$2" == "" ]; then
    echo usage $0 domain.alias domain.ptr
    exit
fi;

ip=`cat /etc/ip`

domainname=$2
domainalias=$1

#add httpd alias
ln -s /www/static/$domainname /www/static/$domainalias
ln -s /www/static/$domainalias /www/static/www.$domainalias
sed -i "s/ServerAlias /ServerAlias $domainalias www.$domainalias /g" /etc/apache2/sites-available/$domainname.conf
apache2ctl restart 2>&1 > /dev/null




