#!/bin/bash
if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [ ! `cat /etc/.installer_version` -eq 000007 ];then 
    printf "\e[1;31mUpdate for 0.07 Only. Already updated  \e[0m\n"
    exit
fi


updatehost="http://n1ck.name/conf/"
#phase one
printf "\e[1;32m%s\e[0m\n" "update fix_perm.sh"

wget -q -O /root/user/fix_perm.sh ${updatehost}/vexim/user/fix_perm.sh
chmod +x /root/user/fix_perm.sh

echo 000008 > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"


