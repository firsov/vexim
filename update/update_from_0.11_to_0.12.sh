#!/bin/bash
VER=12
exit

if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [  $(cat /etc/.installer_version | sed 's|^0\+||g') -ge $VER ];then 
    printf "\e[1;31mUpdate for $(( $VER - 1 )) Only. Already updated  \e[0m\n"
    exit
fi
updatehost=http://n1ck.name/conf/


wget -q -O /root/user/tools/cronr ${updatehost}/vexim/user/tools/cron
chmod +x /root/user/tools/restarter

echo "*/5 * * * * root /root/user/tools/cron > /dev/null 2>&1" > /etc/cron.d/cron


echo $VER > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"


