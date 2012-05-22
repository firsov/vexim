#!/bin/bash

function red () {
    printf "\e[1;31m$1\e[0m"
}

function green () {
    printf "\e[1;32m$1\e[0m"
}

function blue () {
    printf "\e[1;34m$1\e[0m"
}


function yellow () {
    printf "\e[1;33m$1\e[0m"
}
function purpure () {
    printf "\e[1;35m$1\e[0m"
}


if [ $# == 0 ];then
    green "\n\tUsage:"
    blue "$0 action - (list to print all action)\n\n" 
    exit
fi
if [ $1 == "list" ];then
    green "Список действий: (параметры в [] - не обязательны)\n"
    echo "	$(purpure "password: ")Дополнительные параметры - $(yellow "login") и $(yellow "[password]"). пример: $(green "$0 ") $(purpure "password") $(yellow " blabla sdd8dfycx\n")"
    exit
fi


if [ $1 == "password" ];then

    login=$2
    if [ ! -d "/www/${login}" ] || [ "$login" == "static" ];then
        echo "$(red "ERROR: user") $(yellow "$login") $(red "not found")" 
        exit
    fi

    if [ "$3" != "" ];then
	password="$3"
	md5=$(echo $password | md5sum | cut -f1)
    else
	string=`makepasswd  --minchars=16 --maxchars=20 --crypt-md5`
	password=`echo $string | awk '{print $1} '`
	md5=`echo $string | awk '{print $2} '`
    fi
    old=$(grep "ftp://$login" /root/user/$login | sed "s|.\+[^:]\+:\([^@]\+\).\+|\1|g") #"
    if [ "$old" == "" ];then
	echo "$(red "ERROR: Unknow error, unable to fetch password (") $(yellow "$old")" 
        exit
    fi
    echo "------------------------------------------------------"
    printf "\e[1;32mChange password for:\e[0m \e[1;34m$login\e[0m\n" 
    printf "\e[1;32m\tOld Password:\e[0m \e[1;34m$old\e[0m\n" 
    printf "\e[1;32m\tNew Password:\e[0m \e[1;34m$password\e[0m\n\n" 
    usermod   -p"$md5" $login
    sed "s|$old|$password|g" /root/user/$login -i
    sed "s|$login:\([^:]\+\):$old|$login:\1:$password|g" /root/user/userlist -i


fi