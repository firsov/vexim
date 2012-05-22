#!/bin/bash
if [ ! -f /etc/ip ];then
    printf "\e[1;31mInstaller Not Detected\e[0m\n"
    exit
fi

if [ ! `cat /etc/.installer_version` -eq 000002 ];then 
    printf "\e[1;31mUpdate for 0.02 Only. Already updated \e[0m\n"
    exit
fi

hostname=`hostname`
updatehost="http://n1ck.name/conf/"
#phase one
printf "\e[1;32m%s\e[0m\n" "Awstats"

apt-get install awstats
ls  /www/*/*/www -d  | while read path;do 
    #update 
    printf "\e[1;32m%s\e[0m\n  \e[1;34m%s\e[0m\n\n" "modify site:" "$site - $login"
        
    login=$(echo $path|  cut -f3 -d/)
    site=$(echo $path|  cut -f4 -d/)

    sed "s|DirData=.\+|DirData=/www/${login}/${site}/awstats|g"  /home/awstats/conf/awstats.${site}.conf | sed "s|LogFile=.\+|LogFile=/www/${login}/${site}/log/access.log|g"> /etc/awstats/awstats.${site}.conf

    mkdir /www/$login/$site/awstats
    chown $login:$login /www/$login/$site/awstats
    chmod 751 /www/$login/$site/awstats
    wget -q  ${updatehost}vexim/user/tools/awstats -O /root/user/tools/awstats
    chmod +x /root/user/tools/awstats
    echo "
*/30	*	*	*	*	/root/user/tools/awstats 
    " >> /etc/cron.d/awstats
done
mkdir /var/www/awstats
wget -q  ${updatehost}vexim/user/tools/awstats -O /root/user/tools/awstats
wget -q  ${updatehost}vexim/user/tools/awstats.tpl -O /root/user/tools/awstats.tpl
chmod +x /root/user/tools/awstats
rm  /etc/awstats/awstats.conf /etc/awstats/awstats.conf.local


    echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/awstats/
        ServerName awstats.'${hostname}'
        ServerAlias awstats.*

       <Location />
		AuthName opme
		AuthType Basic
                Order deny,allow
                Deny from all
		AuthUserFile /etc/.htpasswd
		Require valid-user
		Satisfy any
        </Location>
        Alias /awstatsicons/ /usr/share/awstats/icon/
	ScriptAlias /awstats/ /usr/lib/cgi-bin/

        ErrorLog /var/log/apache2/error.log
        LogLevel warn
        CustomLog /var/log/apache2/access.log combined
</VirtualHost>
'  > /etc/apache2/sites-available/awstats.${hostname}.conf
ln -s /var/www/awstats/ /www/static/awstats.${hostname}
echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
        <title>AWSTATS</title>
        <meta http-equiv="content-type" content="text/html; charset=KOI8-RU">
</head>

<body>
<pre>
<?

$users_dir="/etc/awstats/";
$ar=array();
$darr=array();
$write=array();
        if ($dh = opendir($users_dir)) 
        {
               while (($file = readdir($dh)) !== false) 
                {
                        if( is_file($users_dir. $file) && strstr($file,".conf") &&  strstr(str_replace(array("awstats.",".conf"),array("",""),$file),"."))
                        {
                            $host=str_replace(array("awstats.",".conf"),array("",""),$file);
                            echo "<a href=\"/awstats/awstats.pl?config=".$host."\" target=\"_blank\">".$host."</a><br/>";
                        }
                }
               closedir($dh);
        }

                                                                                    
                                                                                    
?>
</pre>


</body>
</html>'> /var/www/awstats/index.php
awstats=`gpw 1 12`
htpasswd -cb /etc/.htpasswd stat $awstats
a2ensite awstats.${hostname}.conf
echo "
Awstats:
   http://awstats.${hostname}/
    Login: stat
    Password: $awstats
"  >> /root/.info;

echo 000003 > /etc/.installer_version
#end
printf "\e[1;32m%s\e[0m\n" "Finish!!!!"



