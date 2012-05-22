#!/bin/bash
if [ "$2" == "" ]; then
    echo usage $0 alias domain
    exit
fi;

if [ ! -f  /etc/ip ];then
    echo netu /etc/ip
    exit
else
    ip=`cat /etc/ip`
fi
	
domainname=$2
domainalias=$1

flname=`echo "$domainname" | sed 's/[-_.]//g'`
if [ ! -f "/var/log/vhosts/"$domainname"_log" ]; then
    echo "-------------------------------------"
    echo $domainname not found
    exit

fi;


#add httpd and awstats
if [ -d /etc/apache2 ];then
    sh /root/user/tools/apache_alias.sh $1 $2
fi

#add dns
if [ -d /etc/named ] && [ ! -f /etc/named_web/${domainname}.host ];then
sh /root/user/tools/dns.sh $1
fi



