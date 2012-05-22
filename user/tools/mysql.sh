#!/bin/bash
if [ "$2" == "" ]; then
    echo usage $0 db username
    exit
fi;



db=$1
user=$2


db=${db:0:10}
db=`echo "$db" | sed 's/[-_.]//g'`

if [ -d "/var/lib/mysql/db_${db}" ]; then
    echo db_${db} exists
    exit
fi;


mypassword=`pwgen -a 16 1`
echo "create database db_${db};use mysql;GRANT ALL PRIVILEGES ON db_${db}.* TO '${db}'@'localhost'  IDENTIFIED BY '$mypassword' WITH GRANT OPTION;FLUSH PRIVILEGES;" | mysql -uroot
echo "${db}:db_${db}:$mypassword" >> /root/user/myuserlist


echo "-------------SQL---------------" >> ${user}
echo "db: db_${db}"  >> ${user}
echo "login: ${db}"  >> ${user}
echo "password: $mypassword" >> ${user}




#EOS