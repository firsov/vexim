#!/bin/bash
if [ "$2" == "" ]; then
    echo usage $0 dbname username
    exit
fi;

if [ ! -f  /etc/ip ];then
    ip=`ifconfig | grep inet | grep -v 127.0.0 | head -n1 | sed 's/\(.\+\)inet addr:\([^ ]\+\)\(.\+\)/\2/g'`
else
    ip=`cat /etc/ip`
fi
	

domainname=$1
username=$2

#add mysql
sh /root/user/tools/mysql.sh $1 $2


cat $username;


