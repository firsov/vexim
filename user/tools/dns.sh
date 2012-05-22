#!/usr/local/bin/bash
if [ "$1" == "" ]; then
    echo usage $0 domain.name 
    exit
fi;

if [ ! -f  /etc/ip ];then
    ip=`ifconfig | grep inet | grep -v 127.0.0 | head -n1 | sed 's/\(.\+\)inet addr:\([^ ]\+\)\(.\+\)/\2/g'`
else
    ip=`cat /etc/ip`
fi

if [ "$2" != "" ]; then
    ip=$2
fi;

domainname=$1

if [ ! -f /etc/named_web/$domainname.host ];then
#add dns
sed "s/%dom%/$domainname/g" /root/user/tools/dns.tpl| sed "s/%ip%/$ip/g"  > /etc/named_web/$domainname.host
echo "zone \"$domainname\" {
        type master;
        file \"/etc/named_web/$domainname.host\";
};
"       >>  /etc/named_web/vhost.conf
rndc reload
fi

#EOS