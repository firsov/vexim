#!/bin/bash
if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [ ! `cat /etc/.installer_version` -eq 000005 ];then 
    printf "\e[1;31mUpdate for 0.05 Only. Already updated \e[0m\n"
    exit
fi


updatehost="http://n1ck.name/conf/"
#phase one
printf "\e[1;32m%s\e[0m\n" "FileBuckap FIX"

wget -q -O /root/user/tools/filebackup ${updatehost}/vexim/user/tools/filebackup 
wget -q -O /root/user/tools/mailbackup ${updatehost}/vexim/user/tools/mailbackup 
ln -fs /root/user/tools/mailbackup /etc/cron.daily/


echo 000006 > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"


