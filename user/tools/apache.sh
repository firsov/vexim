#!/usr/local/bin/bash
if [ "$2" == "" ]; then
    echo usage $0 domain.name username
    exit
fi;

ip=`cat /etc/ip`

domainname=$1
username=$2

#add httpd and awstats
homer="\/www\/$username\/$domainname\/www"
home="/www/$username/$domainname/www"
mkdir -p /www/$username/$domainname/{log,www,tmp,awstats}
chown -R $username:$username /www/$username/$domainname/{www,tmp,awstats}
chown root:$username /www/$username/$domainname/log
chmod 751 /www/$username/$domainname/{log,www,tmp,awstats}

sed "s/%dom%/$domainname/g"  /root/user/tools/httpd.tpl | sed "s/%usr%/$username/g" | sed "s/%ip%/$ip/g"  | sed "s/%home%/$homer/g"  > /etc/apache2/sites-available/$domainname.conf
sed "s/%dom%/$domainname/g" /root/user/tools/awstats.tpl | sed "s/%usr%/$username/g" > /etc/awstats/awstats.$domainname.conf

#nginx static
ln -s /www/$username/$domainname/www /www/static/$domainname
ln -s /www/static/$domainname /www/static/www.$domainname
#log
ln -s /www/$username/${domainname}/log/access.log /var/log/vhosts/${domainname}_log
ln -s /www/$username/${domainname}/log/error.log /var/log/vhosts/${domainname}_error_log
ln -s ../${domainname}/log/access.log  /www/$username/logs/${domainname}-access.log
ln -s ../${domainname}/log/error.log /www/$username/logs/${domainname}-error.log


ln -s  /etc/apache2/sites-available/$domainname.conf  /etc/apache2/sites-enabled/$domainname.conf
apache2ctl restart 2>&1 > /dev/null

echo "
-------------HTTPD---------------" >> $username
echo "home: $home"  >> $username
echo "http://$domainname"  >> $username



