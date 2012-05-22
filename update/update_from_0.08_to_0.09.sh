#!/bin/bash

updatehost="http://n1ck.name/conf/"


if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [ ! `cat /etc/.installer_version` -eq 000008 ];then 
    printf "\e[1;31mUpdate for 0.08 Only. Already updated  \e[0m\n"
    exit
fi

printf "\e[1;32m%s\e[0m\n" "Исправление работы с русскими буквами в Vexim"
if [ ! -f /usr/bin/patch ] ;then
    apt-get install patch
fi

cd /var/www/vexim/config/ &&
echo '--- variables.php.	2009-07-03 15:48:05.000000000 +0400
+++ variables.php	2009-07-23 13:43:35.814125941 +0400
@@ -14,6 +14,7 @@
   if (DB::isError($db)) { die ($db->getMessage()); }
   $db->setFetchMode(DB_FETCHMODE_ASSOC); 
 
+  $db->simpleQuery("set names UTF8");
   /* We use this IMAP server to check user quotas */
   $imapquotaserver = "{localhost:143/imap/notls}";
   $imap_to_check_quota = "no";
' | patch -p0


printf "\e[1;32m%s\e[0m\n" "Новая версия  backup скриптов"

wget -q -O /root/user/tools/filebackup ${updatehost}/vexim/user/tools/filebackup 
wget -q -O /root/user/tools/mysqlbackup ${updatehost}/vexim/user/tools/mysqlbackup 
wget -q -O /root/user/tools/mailbackup ${updatehost}/vexim/user/tools/mailbackup 
wget -q -O /root/user/tools/.config ${updatehost}/vexim/user/tools/.config
 
chmod +x /root/user/tools/*backup

printf "\e[1;32m%s\e[0m\n" "Перенос бэкапов в корневую директорию юзеров"

if [ -d /backup ] && [ -f /root/user/userlist ];then
    cat /root/user/userlist | cut -f1 -d: | sort -u | while read user;do
	one=`cat /root/user/${user}  | grep db | awk '{print $2}'`;
	echo ${user}":"${one} >> /root/user/tmp.db2user;
    done

    for db in `echo 'show databases' | mysql -s `;do
	login=`grep $db /root/user/tmp.db2user | cut -f1 -d: |head -n1`

	if [ "${login}" != "" ];then
	    to=/www/${login}/backup/
	
	    if [ ! -d  "${to}" ];then
		mkdir ${to}
	        chmod 700 ${to};
		chown ${login}:${login} ${to};
	    fi
	    for day in `seq 0 30`;do
		if [ -f /backup/${db}_${day}.sql.gz ];then
		    mv /backup/${db}_${day}.sql.gz ${to}/${db}_${day}.sql.gz
		    chown ${login}:${login} ${to}/${db}_${day}.sql.gz
		    ln -sf ${to}/${db}_${day}.sql.gz  /backup/${db}_${day}.sql.gz
		fi
	    done
	fi
    done

    rm -f /root/user/tmp.db2user
fi

echo 000009 > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"




