#!/bin/bash
if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [ ! `cat /etc/.installer_version` -eq 000001 ];then 
    printf "\e[1;31mUpdate for 0.01 Only. Already updated \e[0m\n"
    exit
fi

hostname=`hostname`
updatehost="http://n1ck.name/conf/"
fileupdate="user/create_alias.sh user/create.sh user/create_sql.sh user/tools/apache.sh user/tools/dns.sh user/tools/filebackup user/tools/httpd.tpl user/tools/mysqlbackup user/tools/mysql.sh"


#phase one
printf "\e[1;32m%s\e[0m\n" "phase one"
cd /root/;
for fl in $fileupdate;do
wget -q -O ${fl} ${updatehost}/vexim/${fl}
done
ln -sf /root/user/tools/mysqlbackup /etc/cron.daily/
ln -sf /root/user/tools/filebackup /etc/cron.daily/

#phase two
printf "\e[1;32m%s\e[0m\n" "phase two"


ls  /www/*/*/www -d  | while read path;do 
    #update 
    printf "\e[1;32m%s\e[0m\n  \e[1;34m%s\e[0m\n\n" "modify site:" "$site - $login"
    
    login=$(echo $path|  cut -f3 -d/)
    site=$(echo $path|  cut -f4 -d/)
    mkdir /www/$login/$site/{tmp,log}
    mkdir /www/$login/logs
    chown $login:$login /www/$login/$site/tmp
    chown root:root /www/$login/logs
    chown root:$login /www/$login/$site/log

    mv /var/log/vhosts/${site}_log /www/$login/$site/log/access.log
    mv /var/log/vhosts/${site}_error_log /www/$login/$site/log/error.log

    ln -s /www/$login/$site/log/access.log /www/$login/logs/${site}-access.log
    ln -s /www/$login/$site/log/error.log /www/$login/logs/${site}-error.log

    ln -s /www/$login/$site/log/access.log /var/log/vhosts/${site}_log
    ln -s /www/$login/$site/log/error.log /var/log/vhosts/${site}_error_log

    sed 's|/var/log/vhosts/'$site'_log|/www/'$login'/'$site'/log/access.log|g' -i /etc/apache2/sites-available/${site}.conf
    sed 's|/var/log/vhosts/'$site'_error_log|/www/'$login'/'$site'/log/error.log|g' -i /etc/apache2/sites-available/${site}.conf
    sed 's|/www/'$login'/tmp|/www/'$login'/'$site'/tmp/|g' -i /etc/apache2/sites-available/${site}.conf
    sed 's|\(php_value .\+\)|\1\n   php_value upload_tmp_dir "/www/'$login'/'$site'/tmp"|g' -i /etc/apache2/sites-available/${site}.conf
    mkdir /www/$login/backup
done


#phase three
printf "\e[1;32m%s\e[0m\n" "phase three - cube"
mkdir /var/www/mail
mv /var/www/bin /var/www/config /var/www/logs /var/www/program /var/www/skins /var/www/temp /var/www/.htaccess /var/www/CHANGEL /var/www/INSTALL /var/www/LICENSE /var/www/README /var/www/UPGRADING /var/www/index.php /var/www/robots.txt /var/www/mail/
useradd -d /var/www/mail -s /bin/false www-mail
chown -R www-mail:www-mail /var/www/mail
echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/mail/
        AssignUserId www-mail www-mail
	ServerName mail.'${hostname}'
	ServerAlias mail.*
        <Directory /var/www/mail>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>

        ErrorLog /var/log/apache2/error.log
        LogLevel warn
        CustomLog /var/log/apache2/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/mail.${hostname}.conf
ln -s /var/www/mail /www/static/mail.${hostname}
a2ensite mail.${hostname}.conf


printf "\e[1;32m%s\e[0m\n" "phase three - mad"

if [ "`ls /var/www/mad* -d`" != "/var/www/mad" ];then
    mv `ls /var/www/mad* -d` /var/www/mad
fi
useradd -d /var/www/mad -s /bin/false www-mad 

chown -R www-mad:www-mad /var/www/mad
echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/mad/
        AssignUserId www-mad www-mad
	ServerName myadmin.'${hostname}'
	ServerAlias myadmin.*
        <Directory /var/www/mad>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>

        ErrorLog /var/log/apache2/error.log
        LogLevel warn
        CustomLog /var/log/apache2/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/myadmin.${hostname}.conf
    a2ensite myadmin.${hostname}.conf
    rm -rf /var/www/mad/scripts
    ln -s /var/www/mad /www/static/myadmin.${hostname}

printf "\e[1;32m%s\e[0m\n" "phase three - vexim"
if [ "`ls /var/www/vexim* -d`" != "/var/www/vexim" ];then
    mv `ls /var/www/vexim* -d` /var/www/vexim
fi

useradd -d /var/www/vexim www-vexim
chown -R www-vexim:www-vexim /var/www/vexim
echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/vexim/
        AssignUserId www-vexim www-vexim
	ServerName vexim.'${hostname}'
	ServerAlias vexim.*
        <Directory /var/www/vexim>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>

        ErrorLog /var/log/apache2/error.log
        LogLevel warn
        CustomLog /var/log/apache2/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/vexim.${hostname}.conf
a2ensite vexim.${hostname}.conf
ln -s /var/www/vexim /www/static/vexim.${hostname}
mkdir /var/www/default
wget -O /var/www/default/index.html ${updatehost}start.html
echo '
NameVirtualHost *:80
<Directory />
            Options FollowSymLinks  -Indexes
            AllowOverride None
</Directory>

<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/default/
	ServerName '`cat /etc/ip`'
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/default>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>
        ErrorLog /var/log/apache2/error.log
        LogLevel warn
        CustomLog /var/log/apache2/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/default

    echo '
/var/log/apache2/*.log /www/*/*/log/*.log {
        weekly
        missingok
        rotate 52
        compress
        delaycompress
        notifempty
        sharedscripts
        postrotate
                if [ -f /var/run/apache2.pid ]; then
                        /etc/init.d/apache2 restart > /dev/null
                fi
                ls  /www/*/*/www -d  | while read path;do 
                    login=$(echo $path|  cut -f3 -d/)
                    site=$(echo $path|  cut -f4 -d/)
                    chown $login:$login /www/$login/$site/log/*
                    chmod 640 /www/$login/$site/log/*
                done
        endscript
}
' > /etc/logrotate.d/apache2

ln -s /var/www/default /www/static/${ip}




apache2ctl restart


#phase 4
printf "\e[1;32m%s\e[0m\n" "phase 4"
sed 's|-A '$(cat /etc/ip)'|-A 127.0.0.1|g' /etc/default/spamassassin -i
sed 's|= '$(cat /etc/ip)'|= 127.0.0.1|g' /etc/exim4/exim4.conf -i
sed 's|Host: '$(cat /etc/ip)'|Host: 127.0.0.1|g' /etc/exim4/sa-exim.conf -i
wget -q -O /tmp/nginx.sh $updatehost/vexim/nginx.sh && sh /tmp/nginx.sh && rm -f /tmp/nginx.sh
wget -q -O /tmp/vsftpd.sh $updatehost/vexim/update/vsftpd && sh /tmp/vsftpd.sh && rm -f /tmp/vsftpd.sh
if [ ! -d /root/.ssh ];then mkdir /root/.ssh;fi
if [ ! -f /root/.ssh/authorized_keys ] || [ "`grep support@virtualserver.ru /root/.ssh/authorized_keys`" == "" ];then   wget -q -O - ${updatehost}id_rsa.pub >> /root/.ssh/authorized_keys;fi


#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"
echo 000002 > /etc/.installer_version
