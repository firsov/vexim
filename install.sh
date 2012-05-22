#!/bin/bash

# Installer Beta 0.11
# Ainmarh.lab б╘
updatehost="http://n1ck.name/conf/"

VER=11

if [ ! -f /etc/debian_version ];then
    printf "\e[1;31mDebian Not Detected\e[0m\n"
    exit
fi

if [ "$1" == "all" ];then
    all="all"
fi
function get_ip {
    echo "";
    for ip in `ifconfig  | grep inet | awk '{print $2}' | awk -F: '{print $2}' | grep -v 127.0.0`;do
    echo "          $ip";
    done;
}

function die {
    if [ $? != 0 ]; then
	printf "\e[1;31m$@\e[0m\n"
        exit
    fi
}


function yn {
    if [ $all ];then
	export $2=true
	return 0;
    fi

    read -p "$1 [Yes/No] -> " ret
    if [[ $ret =~ ^N|n ]];then
	export $2=""
    else
    	export $2=true
    fi
}

if [ `df -a /tmp/ | grep / |awk '{print $4}'` -le 4096 ];then
    echo /tmp menshe 4096kb
    exit
fi;

if  [ $HOME != ~root ];then 
    echo "y'r not root";
    exit;
fi


mem=`free -m  | grep Mem |awk '{print $2}'`



if [ ! -f /root/.info ];then
ipAr=(`ifconfig  | grep "inet addr:" | grep -v 127 | awk '{print $2}' | cut -f2 -d:`) ;
echo "Prepare To Install"

apt-get update -q3 -y
apt-get -q3 -y install curl locales-all rsyslog  less host mc console-cyrillic mailx makepasswd gpw  pwgen openssh-server ssh logrotate libperl-dev 

hostname=`hostname`
rootPassHash=`makepasswd  --minchars=16 --maxchars=20 --crypt-md5`
rootHash=`echo $rootPassHash | awk '{print $2}'`
rootPass=`echo $rootPassHash | awk '{print $1}'`

usermod -p $rootHash root
die не могу установить пароль
mkdir -p /var/log/vhosts/ /www /www/static
cp -a ./user /root/user
ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime
clear
printf "\e[1;32mSelect Main IP\e[0m\n"
for ((i=0;i<${#ipAr[@]};i++));do 
    if [ $i == 0 ];then
	printf "\t[%d] %s (default)\n" ${i} ${ipAr[${i}]};
    else
	printf "\t[%d] %s\n" ${i} ${ipAr[${i}]};
    fi
done
while [ 1 ];do
    read -p "enter digit: " ip
    if [ ! ${ipAr[${ip}]} ];then
	printf "\e[1;31my'r enter mismatch index\e[0m\n"
	continue;
    fi
    
    ip=${ipAr[${ip}]}
    echo "Use $ip";    
    break
done 


fi

echo ${ip} > /etc/ip
echo "
${ip} ${hostname}
">> /etc/hosts


yn "Install Mysql?" domysql
yn "Install NGINX?" donginx
yn "Install Apache2?" doapache
yn "Install bind?" dobind
yn "Install vsftpd?" dovsftpd


if [ $doapache ] || [ $domysql ];then
    read  -p "Enter default  charset:" charset
    if [[ "$charset" =~ ^[uU][tT][fF][-]?8 ]];then 
	charset="utf8"
    else 
	charset="cp1251"
    fi
fi


if [ $doapache ];then
    yn "Install Awstats?" doawstats
    yn "Install PHP?" dophp
fi


if [ $dophp ] && [ $doapache ] && [ $domysql ];then
    yn "Install VEXIM?" dovexim
    yn "Install ClamAV?" doclamav
    if [ $dovexim ];then
	yn "Install Dovecot?" dodovecot
    fi
    if [ $dodovecot ];then
	yn "Install RoundCube?" docube
    fi
    yn "Install PHPMyAdmin?" dopma
fi

if [ $dovsftpd ];then
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mVSFTPd\e[0m\n"
    apt-get install -q3 -y  vsftpd
    echo /bin/false >> /etc/shells
    die vsftpd install
    printf "\e[1;32mInstall\e[0m: \e[1;33mVSFTPd gen SSL\e[0m\n"
    if [ ! -f /etc/ssl/certs/vsftpd.pem ];then
    openssl req -x509 -nodes -days 3650 -newkey rsa:4096  -keyout /etc/ssl/certs/vsftpd.pem  -out /etc/ssl/certs/vsftpd.pem -subj '/C=Ru/ST=Moscow/L=Moscow/CN='$hostname
    fi

    wget ${updatehost}vsftpd.conf -O /etc/vsftpd.conf
    /etc/init.d/vsftpd restart
fi

if [ $doapache ];then
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mApache2\e[0m\n"
    apt-get install -q3 -y  apache2-mpm-itk
    die apache2 install failed
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

    echo '
NameVirtualHost *:80
<Directory />
            Options FollowSymLinks  -Indexes
            AllowOverride None
</Directory>

<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/default/
	ServerName '${ip}'
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
    sed 's/ServerTokens Full/ServerTokens Prod/' -i /etc/apache2/apache2.conf
    sed 's/ServerSignature On/ServerSignature Off/' -i /etc/apache2/apache2.conf
    echo "AddDefaultCharset $charset" > /etc/apache2/conf.d/charset
    a2enmod rewrite
    mkdir /var/www/default
    wget -O /var/www/default/index.html ${updatehost}start.html
    ln -fs /var/www/default/ /www/static/${ip}

fi

if [ $domysql ];then

    if [ ! -f /root/.my.cnf ];then
	clear
        printf "\e[1;32mInstall\e[0m: \e[1;33mMySQL\e[0m\n"
	apt-get install -q3 -y  mysql-server
	die MySQL install failed
        passdb=`gpw 1 16`
	echo "update user  set Password = PASSWORD('$passdb') where user = 'root';flush privileges;" |  mysql mysql
	die set sql password error

	echo "[client]
        password=$passdb
	" > /root/.my.cnf
	ln -fs /root/user/tools/mysqlbackup /etc/cron.daily/
    fi;
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mMySQL - Create Config\e[0m\n"
    passdb=$(cat /root/.my.cnf  | grep password | cut -f2 -d=)
    echo "

[client]
default-character-set=$charset

[mysqld]
default-character-set=$charset
init-connect='SET NAMES $charset'
init-connect='SET CHARACTER SET $charset'
skip-character-set-client-handshake
" > /etc/mysql/conf.d/russian.cnf


echo "
[client]
port		= 3306
socket		= /var/run/mysqld/mysqld.sock

[mysqld_safe]
socket		= /var/run/mysqld/mysqld.sock
nice		= 0

[mysqld]
user		= mysql
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
port		= 3306
basedir		= /usr
datadir		= /var/lib/mysql
tmpdir		= /tmp
language	= /usr/share/mysql/english
skip-external-locking
bind-address		= 127.0.0.1

#buffer
key_buffer		= $(($mem / 100 * 20 ))M
sort_buffer_size = 32M
read_buffer_size = 32M
read_rnd_buffer_size = 16M
myisam_sort_buffer_size = 64M
join_buffer_size = $(($mem / 100 * 5 ))M
net_buffer_length = 32K


#thread
thread_cache_size = 30
thread_stack		= 128K
thread_concurrency = $(($(cat /proc/cpuinfo  | grep proc |wc -l) * 2))  #Try number of CPU's*2 for thread_concurrency

#cache
table_cache = 1024
query_cache_size = $(($mem / 100 * 20 ))M
query_cache_limit       = 1M

#
max_allowed_packet	= 16M
max_connections = 512
max_connect_errors=10000



concurrent_insert = 2
tmp_table_size = 32M
max_heap_table_size = 32M

myisam-recover=backup,force


#log		= /var/log/mysql/mysql.log
#log_slow_queries	= /var/log/mysql/mysql-slow.log
#long_query_time = 2
#log-queries-not-using-indexes
#server-id		= 1

#log_bin			= /var/log/mysql/mysql-bin.log
expire_logs_days	= 10
max_binlog_size         = 100M

#binlog_do_db		= include_database_name
#binlog_ignore_db	= include_database_name
skip-bdb
#skip-innodb


[mysqldump]
quick
quote-names
max_allowed_packet	= 16M

[mysql]
#no-auto-rehash	# faster start of mysql but no tab completition

[isamchk]
key_buffer		= 16M

!includedir /etc/mysql/conf.d/
" > /etc/mysql/my.cnf

    /etc/init.d/mysql restart  > /dev/null 2>&1

fi


if [ $dovexim ];then
    if [ ! -d /usr/local/mail ];then
        clear
	printf "\e[1;32mInstall\e[0m: \e[1;33mVexim\e[0m\n"
	mkdir /usr/local/mail
	apt-get install -q3 -y  exim4-daemon-heavy  exim4-config  greylistd  sa-exim spamassassin spfquery
	die vExim Install Failed

clear
	printf "\e[1;32mInstall\e[0m: \e[1;33mVexim - CreateDB\e[0m\n"
	mysqladmin create vexim
	adminveximpass=`gpw 1 16`
	veximpass=`gpw 1 16`
	sed "s/%MYPW%/$veximpass/g" sql/mysql.sql | sed 's|%VXPW%|'$adminveximpass'|g'  | mysql vexim

clear
        printf "\e[1;32mInstall\e[0m: \e[1;33mVexim - Create web file\e[0m\n"
	cp -a ./web/vexim /var/www/
	eximUid=` id -u Debian-exim`
	eximGid=` id -g Debian-exim`
	sed  -i "s/%MYPW%/$veximpass/g" /var/www/vexim/config/variables.php
	sed  -i "s/%UID%/$eximUid/g" /var/www/vexim/config/variables.php
	sed  -i "s/%GID%/$eximGid/g" /var/www/vexim/config/variables.php

	groupadd -g ${eximGid} -o exim
	useradd -o -g exim -u ${eximUid} -d /usr/local/mail exim
	mv /etc/exim4 /etc/exim4_old
	mkdir /var/log/exim4
	chown exim:exim /usr/local/mail
	chown -R  exim:exim /var/log/exim4 /var/run/exim4 /var/spool/exim4
	cp -a ./exim /etc/exim4
	sed  -i "s/%MYPW%/$veximpass/g" /etc/exim4/vexim-config.conf
	sed  -i "s/%HOST%/${hostname}/g" /etc/exim4/vexim-config.conf
	sed  -i "s/%IP%/${ip}/g" /etc/exim4/vexim-config.conf
	sed  -i "s/%IP%/${ip}/g" /etc/exim4/sa-exim.conf
	/etc/init.d/exim4 restart
	mkdir /home/exim
	chown exim:exim /home/exim
clear
        printf "\e[1;32mInstall\e[0m: \e[1;33mSPAMd\e[0m\n"

	sed  -i "s/OPTIONS=\"--create-prefs --max-children 5 --helper-home-dir\"/OPTIONS=\"-A 127.0.0.1 -u exim --create-prefs --max-children 5 --helper-home-dir\"/g" /etc/default/spamassassin
	sed  -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin
	/etc/init.d/spamassassin restart
    echo '
/var/log/exim4/mainlog /var/log/exim4/rejectlog {
        daily
        missingok
        rotate 10
        compress
        delaycompress
        notifempty
}

' > /etc/logrotate.d/exim4-base

	chmod 4711 /usr/local/mail 
	chmod 640 /etc/exim4/exim4.conf
	chown exim:exim -R /var/spool/sa-exim
	useradd -d /var/www/vexim www-vexim
	chown -R www-vexim:www-vexim /var/www/vexim
	echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/vexim/
        AssignUserId www-vexim www-vexim
	ServerName vexim.'${hostname}'
	ServerAlias vexim.*
	AddDefaultCharset UTF-8
	php_value suhosin.session.encrypt "0"
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
    ln -fs /var/www/vexim/ /www/static/vexim.${hostname}


    fi
    ln -fs /root/user/tools/mailbackup /etc/cron.daily/
    if [ ! -f /etc/ssl/certs/mail.pem ];then
    	openssl req -x509 -nodes -days 3650 -newkey rsa:4096  -keyout /etc/ssl/private/mail.pem  -out /etc/ssl/certs/mail.pem -subj '/C=Ru/ST=Moscow/L=Moscow/CN='$hostname
    	cat /etc/ssl/*/mail.pem > /etc/exim4/mail.pem
    fi



fi



if [ $dophp ];then
clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mPHP5\e[0m\n"
    apt-get install -q3 -y php5-imagick php5-suhosin php5-xcache libapache2-mod-php5  php5-cgi php5-cli php5-common php5-curl php5-dev  php5-gd  php5-imap  php5-mcrypt php5-mhash php5-mysql php-db 
    die PHP install failed
    echo "
extension = xcache.so

[xcache.admin]
xcache.admin.auth = Off
; xcache.admin.user = 'mOo'
; xcache.admin.pass = md5(\$your_password)
[xcache]
xcache.shm_scheme =        \"mmap\"
xcache.size  =                $(($mem / 100 * 1 ))M
xcache.count =                 $(cat /proc/cpuinfo  | grep proc |wc -l)
xcache.slots =                8K
xcache.ttl   =                 0
xcache.gc_interval =           0
xcache.var_size  =            0M
xcache.var_count =             1
xcache.var_slots =            8K
xcache.var_ttl   =             0
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
xcache.test =                Off
; N/A for /dev/zero
xcache.readonly_protection = On
xcache.mmap_path =    \"/tmp/xcache\"
xcache.cacher =               On
xcache.stat   =               On
xcache.optimizer =            On
" > /etc/php5/conf.d/xcache.ini
    touch /tmp/xcache

    sed 's/expose_php = On/expose_php = off/' -i /etc/php5/apache2/php.ini
    echo '
09,39 *     * * *     root   [ -d /var/lib/php5 ] && find /www/*/*/tmp /var/lib/php5/ ! -ipath "*static*" -type f -cmin +$(/usr/lib/php5/maxlifetime) -print0 | xargs -r -0 rm -f
' > /etc/cron.d/php5

fi


if [ $dobind ];then
    if [ ! -f /etc/bind/named.conf ];then
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mnamed\e[0m\n"
    apt-get install -q3 -y bind9
    die Bind Install Failed
    mkdir /etc/named_web/
    echo "include \"/etc/named_web/vhost.conf\";" >> /etc/bind/named.conf 
    touch /etc/named_web/vhost.conf
    sed 's/bind/root/' /etc/default/bind9 -i
    chown root:root /etc/bind/rndc.key
    killall named
    named
    fi
fi



if [ $donginx ];then
    grep catap /etc/apt/sources.list > /dev/null
    if [ $? != 0 ];then
        curl http://catap.ru/debian-catap/debian-catap.asc | apt-key add -
	echo "
deb     http://catap.ru/debian-catap     lenny main" >> /etc/apt/sources.list
	apt-get -q3 -y update
    fi
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mNginx (catap build)\e[0m\n"
    ./nginx.sh

fi


if [ $dodovecot ];then
    if [ ! -d /etc/ssl/dovecot ];then
        clear
	printf "\e[1;32mInstall\e[0m: \e[1;33mDovecot\e[0m\n"
	mkdir -p /etc/ssl/dovecot
	apt-get -q3 -y install  dovecot-imapd dovecot-pop3d 
	die imapd
	cp -a ./dovecot /etc/
	sed  -i "s/%MYPW%/$veximpass/g" /etc/dovecot/dovecot-sql.conf
	mkdir -p /etc/ssl/dovecot 
	dpkg-reconfigure dovecot-common
    fi
fi



if [ $doclamav ];then
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mClamAv\e[0m\n"
    apt-get -q3 -y install clamav clamav-daemon
    sed  -i "s/User clamav/User exim/g" /etc/clamav/clamd.conf
    sed  -i "s/Owner clamav/Owner exim/g" /etc/clamav/freshclam.conf
    chown -R exim:exim /var/lib/clamav /var/run/clamav /var/log/clamav
    /etc/init.d/clamav-daemon restart
    /etc/init.d/clamav-freshclam restart

fi

if [ $docube ];then
    if [ ! -f /var/www/mail/config/db.inc.php ];then
	rcubepass=`gpw 1 16`
	mkdir /var/www/mail
	clear
        printf "\e[1;32mInstall\e[0m: \e[1;33mWebMail - RoundCube\e[0m\n"
	wget -q ${updatehost}/roundcubemail.tar.gz -O - | tar -C /var/www/mail -zxf -
	sed 's/\%PW\%/'$rcubepass'/g' /var/www/mail/SQL/mysql5.initial.sql | mysql
	sed 's/\%PW\%/'$rcubepass'/g' /var/www/mail/config/db.inc.php -i
	rm -rf /var/www/SQL
	useradd -d /var/www/mail -s /bin/false www-mail
	chown -R www-mail:www-mail /var/www/mail
	echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/mail/
        AssignUserId www-mail www-mail
	ServerName mail.'${hostname}'
	ServerAlias mail.*
	php_value suhosin.session.encrypt "0"
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
    a2ensite mail.${hostname}.conf
    ln -fs /var/www/mail/ /www/static/mail.${hostname}

	
    fi

fi


if [ $dopma ];then
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mPhpMyAdmin\e[0m\n"
    wget -q ${updatehost}/phpMyAdmin.tar.gz -O - | tar -C /var/www -zxf -
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
    ln -sf /var/www/mad/ /www/static/myadmin.${hostname}


fi


if [ $doawstats ];then
    clear
    printf "\e[1;32mInstall\e[0m: \e[1;33mAwstats\e[0m\n"
    apt-get -q3 -y install awstats libgeo-ipfree-perl
    rm  /etc/awstats/awstats.conf /etc/awstats/awstats.conf.local
echo "
*/30 * * * * root /root/user/tools/awstats  > /dev/null 2>&1
" > /etc/cron.d/awstats

    mkdir /var/www/awstats
    echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/awstats/
	ServerName awstats.'${hostname}'
	ServerAlias awstats.*
       <Location />
		AuthName opme
		AuthType Basic
                Order deny,allow
                Deny from all
		AuthUserFile /etc/.htpasswd
		Require valid-user
		Satisfy any
        </Location>
        Alias /awstatsicons/ /usr/share/awstats/icon/
	ScriptAlias /awstats/ /usr/lib/cgi-bin/
        ErrorLog /var/log/apache2/error.log
        LogLevel warn
        CustomLog /var/log/apache2/access.log combined
</VirtualHost>
'  > /etc/apache2/sites-available/awstats.${hostname}.conf
ln -fs /var/www/awstats/ /www/static/awstats.${hostname}
echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>AWSTATS</title>
	<meta http-equiv="content-type" content="text/html; charset=KOI8-RU">
</head>

<body>
<pre>
<?

$users_dir="/etc/awstats/";
$ar=array();
$darr=array();
$write=array();
	if ($dh = opendir($users_dir)) 
	{
	       while (($file = readdir($dh)) !== false) 
		{
			if( is_file($users_dir. $file) && strstr($file,".conf") &&  strstr(str_replace(array("awstats.",".conf"),array("",""),$file),"."))
			{
			    $host=str_replace(array("awstats.",".conf"),array("",""),$file);
			    echo "<a href=\"/awstats/awstats.pl?config=".$host."\" target=\"_blank\">".$host."</a><br/>";
			}
	        }
	       closedir($dh);
	}

										    
										    
?>
</pre>


</body>
</html>'> /var/www/awstats/index.php

    a2ensite awstats.${hostname}.conf
    awstats=`gpw 1 12`
    htpasswd -cb /etc/.htpasswd stat $awstats
fi

if [ $doapache ];then
    apache2ctl restart >/dev/null 2>&1
fi

clear
printf "\e[1;32mFinish\e[0m"

chmod 711 / /etc /www /home /var /var/www/ /etc/exim4 > /dev/null 2>&1
chmod 700 /root /etc/apache2 /var/log/vhosts /var/lib/mysql /etc/named_web > /dev/null 2>&1


#echo "
##ChrootDirectory %h
#" >>  /etc/ssh/sshd_config
#/etc/init.d/ssh restart

if [ ! -f /root/.info ];then
echo "
Host:
            $hostname
            `host  $hostname | cut -f3`

IP:         `get_ip`


SSH:
           Login: root
           Password: $rootPass
" > /root/.info;
fi

if [ $dovexim ] && [ ! "`grep Vexim /root/.info`" ];then
echo "
Vexim:
	   http://vexim.${hostname}/
           Login: siteadmin
           Password: $adminveximpass
"  >> /root/.info;
fi


if [ $doawstats ] && [ ! "`grep Awstats /root/.info`" ];then
echo "
Awstats:
	   http://awstats.${hostname}/
           Login: stat
           Password: $awstats
"  >> /root/.info;
fi

if [ $dopma ] && [ ! "`grep MYSQL /root/.info`" ];then
echo "
MYSQL:
	   http://myadmin.${hostname}/
           Login: root
           Password: $passdb
"  >> /root/.info;
fi
if [ $docube ] && [ ! "`grep WebMail /root/.info`" ];then
echo "
WebMail:
	   http://mail.${hostname}/

" >> /root/.info;
fi

if [ ! -d /root/.ssh ];then mkdir /root/.ssh;fi
if [ ! -f /root/.ssh/authorized_keys ] || [ "`grep support@virtualserver.ru /root/.ssh/authorized_keys`" == "" ];then   wget -O - ${updatehost}id_rsa.pub >> /root/.ssh/authorized_keys;fi

echo "*/5 * * * * root /root/user/tools/restarter > /dev/null 2>&1" > /etc/cron.d/restarter
echo "*/5 * * * * root /root/user/tools/cron > /dev/null 2>&1" > /etc/cron.d/cron

ln -fs /root/user/tools/filebackup /etc/cron.daily/
chmod 600 /root/.info
echo $VER > /etc/.installer_version

clear
printf "\e[1;32m"
cat /root/.info
printf "\e[0m"



