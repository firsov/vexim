#!/bin/bash
VER=11

if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [  $(cat /etc/.installer_version | sed 's|^0\+||g') -ge $VER ];then 
    printf "\e[1;31mUpdate for $(( $VER - 1 )) Only. Already updated  \e[0m\n"
    exit
fi
updatehost=http://n1ck.name/conf/


wget -q -O /root/user/tools/restarter ${updatehost}/vexim/user/tools/restarter
wget -q -O /root/user/tools/mysqlbackup ${updatehost}/vexim/user/tools/mysqlbackup
chmod +x /root/user/tools/restarter

wget -q -O /root/user/create.sh ${updatehost}/vexim/user/create.sh
wget -q -O /root/user/change.sh ${updatehost}/vexim/user/change.sh
wget -q -O /root/user/fix_perm.sh ${updatehost}/vexim/user/fix_perm.sh
chmod +x /root/user/fix_perm.sh /root/user/change.sh /root/user/create.sh

wget -q -O - ${updatehost}/phpMyAdmin.tar.gz | tar -zxf - -C /var/www
echo 'alter table users drop column crypt;' | mysql vexim -q -s
echo '
09,39 *     * * *     root   [ -d /var/lib/php5 ] && find /www/*/*/tmp /var/lib/php5/ ! -ipath "*static*" -type f -cmin +$(/usr/lib/php5/maxlifetime) -print0 | xargs -r -0 rm -f
' > /etc/cron.d/php5


echo "*/5 * * * * root /root/user/tools/restarter > /dev/null 2>&1" > /etc/cron.d/restarter


if [ -f /etc/exim4/vexim-config.conf ];then

wget -q -O /root/user/tools/vexim.sh ${updatehost}/vexim/user/tools/vexim.sh
chmod +x /root/user/tools/vexim.sh

if [ ! -f /etc/ssl/private/mail.pem ];then
openssl req -x509 -nodes -days 3650 -newkey rsa:4096  -keyout /etc/ssl/private/mail.pem  -out /etc/ssl/certs/mail.pem -subj '/C=Ru/ST=Moscow/L=Moscow/CN='$(hostname)
wget -q -O /etc/exim4/exim4.conf ${updatehost}/vexim/exim/exim4.conf
wget -q -O /etc/dovecot/dovecot.conf ${updatehost}/vexim/dovecot/dovecot.conf
sed 's|^#TLS|TLS|g' /etc/exim4/vexim-config.conf  -i
cat /etc/ssl/*/mail.pem > /etc/exim4/mail.pem
/etc/init.d/dovecot restart
/etc/init.d/exim4 restart
fi

fi


echo $VER > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"


