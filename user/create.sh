#!/bin/bash
if [ "$2" == "" ]; then
    echo usage $0 domain.name username
    exit
fi;

if [ ! -f  /etc/ip ];then
    echo netu /etc/ip
    exit
else
    ip=`cat /etc/ip`
fi

domainname=$1
username=$2

flname=`echo "$domainname" | sed 's/[-_.]//g'`
if [ -f "/var/log/vhosts/"$domainname"_log" ]; then
    echo "-------------------------------------"
    echo $domainname already added
    exit

fi;

if [ ! -d "/www/$username" ]; then


#add user

string=`makepasswd  --minchars=16 --maxchars=20 --crypt-md5`
password=`echo $string | awk '{print $1} '`
md5=`echo $string | awk '{print $2} '`


useradd -m -s /bin/false -d /www/$username -p"$md5" $username
mkdir -p /www/$username/logs
chmod 751 /www/$username
mkdir /www/$username/backup
chmod 750 /www/$username/backup

echo $username:$domainname:$password >> /root/user/userlist
echo "-------------SYSTEM---------------" >> /root/user/$username
echo "FTP access (with ssl)"  >> /root/user/$username
echo "url ftp://$username:$password@$ip/" >> /root/user/$username
echo "login: $username"  >> /root/user/$username
echo "password: $password" >> /root/user/$username

fi;

#add mysql
if [ -f /root/.my.cnf ];then
    sh /root/user/tools/mysql.sh $1 $2
fi

#add httpd and awstats
if [ -d /etc/apache2 ];then
    sh /root/user/tools/apache.sh $1 $2
fi

#add dns
if [ -d /etc/bind ];then
    sh /root/user/tools/dns.sh $1 
fi
#add vexim
if [ -d /usr/local/mail ];then
    sh /root/user/tools/vexim.sh $1 $2
fi

cat /root/user/$username;


