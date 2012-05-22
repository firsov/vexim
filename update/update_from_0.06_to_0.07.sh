#!/bin/bash
if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [ ! `cat /etc/.installer_version` -eq 000006 ];then 
    printf "\e[1;31mUpdate for 0.06 Only. Already updated  \e[0m\n"
    exit
fi


updatehost="http://n1ck.name/conf/"
#phase one
printf "\e[1;32m%s\e[0m\n" "FileBuckap Realy FIX and MailBuckap"

wget -q -O /root/user/tools/filebackup ${updatehost}/vexim/user/tools/filebackup 
wget -q -O /root/user/tools/mailbackup ${updatehost}/vexim/user/tools/mailbackup 
chmod +x /root/user/tools/*backup

echo 000007 > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"


