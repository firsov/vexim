#!/bin/bash
if [ "$2" == "" ]; then
    echo usage $0 domain username
    exit
fi;



domain=$1
user=$2

if [ -d "/usr/local/mail/${domain}" ]; then
    echo ${domain} exists
    exit
fi;

id=$(id -u exim)
gid=$(id -g exim)

password=$(pwgen -a 16 1)
echo "INSERT INTO domains  VALUES ('','${domain}','/usr/local/mail/${domain}',${id},${gid},0,0,'local',0,0,0,1,0,0,0,0,2,5);"  | mysql vexim
domid=$(echo "select domain_id from domains where domain = '$domain'" |mysql vexim -q -s) #'
echo "INSERT INTO users  VALUES ('',$domid,'postmaster','postmaster@${domain}','${password}',${id},${gid},'/usr/local/mail/${domain}/postmaster/Maildir','/usr/local/mail/${domain}/postmaster','local',1,0,0,0,0,0,0,0,1,NULL,NULL,0,0,0,'Domain Admin',0,0,NULL,NULL);"  | mysql vexim 


echo "-------------Vexim---------------" >> ${user}
echo "login: postmaster@${domain}"  >> ${user}
echo "password: $password" >> ${user}

mkdir /usr/local/mail/${domain}/postmaster -p
chown -R exim:exim /usr/local/mail/${domain}/
chmod u=rwx,g+s /usr/local/mail/${domain}/
#EOS
