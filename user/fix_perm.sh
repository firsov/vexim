#!/bin/bash

if [ "$1" != "" ];then
users=$@
printf "\e[1;32m%s\e[0m \e[1;31m%s\e[0m\n" "Вы выбрали следующих пользователей: $users"
else
printf "\e[1;32m%s\e[0m \e[1;31m%s\e[0m\n" "Утилита вызвана без списка пользователей. Для исправления доступа для всех пользователей нажмите enter, для отмены нажмите Ctrl-C"
read yesno
users=`ls /www`
fi

chmod 700 /var/log/nginx /var/log/apache2 /etc/apache2 
cd /www
for user in $users; do
    if [ -d "$user" ];then 
        if [ -d "$user/backup" ];then 
                printf "\e[1;32m%s\e[0m \e[1;31m%s\e[0m\n" "Работаем с пользователем  - "  "$user"
                chown $user:$user /www/$user
		chown $user:$user /www/$user/*
                chown root:$user /www/$user/{logs,backup};
                chown root:$user /www/$user/*/log;
                chown -R $user:$user /www/$user/*/{tmp,www,awstats};

                chmod 711 /www/$user;
                chmod o=x /www/$user/*;
                chmod 750 /www/$user/{logs,backup};
                chmod 750 /www/$user/*/log;
                chmod 751 /www/$user/*/{www,tmp,awstats};
                chmod 600 -R /www/$user/*/www/*;

                find /www/$user/*/www/ -type f -iregex ".*\.\(jpg\|jpeg\|gif\|png\|ico\|css\|zip\|tgz\|gz\|rar\|bz2\|doc\|xls\|exe\|pdf\|ppt\|txt\|tar\|wav\|bmp\|rtf\|js\|avi\|js\|mov\|mpeg\|mpg\|mp3\|swf\|vob\|xml\)\$"  -exec chmod 664 {} \;
                find /www/$user/*/www/* -type d -exec chmod 711 {} \;

	fi
    fi;
done;
printf "\e[1;32m%s\e[0m\n" "Fixiing Finish!!!!"

