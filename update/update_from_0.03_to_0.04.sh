#!/bin/bash
if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [ ! `cat /etc/.installer_version` -eq 000003 ];then 
    printf "\e[1;31mUpdate for 0.03 Only. Already updated  \e[0m\n"
    exit
fi

hostname=`hostname`
updatehost="http://n1ck.name/conf/"
#phase one
printf "\e[1;32m%s\e[0m\n" "Vexim with ru_RU locale"

wget -q -O - ${updatehost}/vexim.tar | tar -xf - -C /tmp
cp /var/www/vexim/config/variables.php /tmp/vexim/web/vexim/config/
cp -R /tmp/vexim/web/vexim/* /var/www/vexim/
rm -rf /tmp/vexim
echo 000004 > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"


