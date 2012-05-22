#!/bin/bash
updatehost="http://n1ck.name/conf/"
if [ ! -f /etc/ip ];then
    echo install.sh before
    exit
fi
ip=`cat /etc/ip`
lo=`ifconfig | grep inet|grep 127.0.0. |sed 's/inet addr://g' | awk '{print $1}' | head -n1`

if [ "$lo" == ""  ]; then
    echo no lo iface
    exit
fi

grep catap /etc/apt/sources.list > /dev/null  2>&1
if [ $? != 0 ];then
        curl http://catap.ru/debian-catap/debian-catap.asc | apt-key add -
        echo "
deb     http://catap.ru/debian-catap     lenny main" >> /etc/apt/sources.list
        apt-get update
fi

grep RPA /etc/apache2/httpd.conf > /dev/null 2>&1

if [ $? != 0 ];then
    apt-get install libpcre3-dev make g++  libperl-dev apache2-threaded-dev
    wget ${updatehost}rpaf.tar.gz -O - | tar -zxf -
    apxs2 -ica mod_rpaf-0.5/mod_rpaf-2.0.c
    echo "LoadModule rpaf_module /usr/lib/apache2/modules/mod_rpaf-2.0.so
RPAFenable On
RPAFproxy_ips $lo $ip
" > /etc/apache2/httpd.conf
    apache2ctl restart
fi

grep $lo:80 /etc/apache2/ports.conf > /dev/null 2>&1

if  [ $? != 0 ];then

    sed 's/Timeout 300/Timeout 15/' /etc/apache2/apache2.conf -i
    sed 's/KeepAlive On/KeepAlive off/' /etc/apache2/apache2.conf -i
    echo "Listen $lo:80" > /etc/apache2/ports.conf
    apache2ctl restart

fi


dpkg -l nginx > /dev/null 2>&1

if [ $? != 0 ];then
    apt-get remove nginx;
fi
if [ -f /usr/sbin/nginx ];then
    mv /usr/sbin/nginx /usr/sbin/nginx.off
fi

apt-get install nginx-catap
ln -s /etc/nginx-catap /etc/nginx
ln -s /usr/sbin/nginx-catap /usr/sbin/nginx
ln -s /usr/share/doc/nginx-catap /usr/share/doc/nginx
ln -s /var/log/nginx-catap /var/log/nginx
ln -s /var/lib/nginx-catap /var/lib/nginx
mkdir -p /var/lib/nginx/body

echo '
/var/log/nginx/*log {
        size 50M
        missingok
        rotate 10
        compress
        delaycompress
        notifempty
        postrotate
                if [ "`pidof nginx`" == "" ]; then
                        nginx;
                else
                    killall -HUP nginx;
                fi
        endscript

}



' > /etc/logrotate.d/nginx


echo '
user www-data;
worker_processes  '$(cat /proc/cpuinfo  | grep proc |wc -l)';
worker_rlimit_nofile 45000;

error_log  /var/log/nginx/error.log;
pid        /var/run/nginx.pid;

events {
    worker_connections  10000;
    use epoll;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    access_log  /dev/null;

    sendfile        on;
    keepalive_timeout  65;
    tcp_nodelay        on;
    gzip  on;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;

}


' > /etc/nginx/nginx.conf

echo '
    server {
	listen '${ip}' default;
        server_name  localhost;
	include /etc/nginx/fastcgi_params;

        location / {

            limit_req zone=html burst=30  nodelay;
	    ssi on;
            proxy_pass   http://'$lo';

        }
        location @proxy {
	    access_log  /dev/null;
	    #some trick for block XSpider
	    if ( $http_user_agent ~* XSpider|Nessus ) {
		    return 403;
	    }
            limit_req zone=html burst=30  nodelay;
            proxy_pass  http://'$lo';
        }

        location ~* ^.+\.flv$ {
            flv;
            root   /www/static/$host;
            access_log  /var/log/nginx/static.access_log  combined buffer=64k;
            error_log   /var/log/nginx/static.error_log;
            try_files $uri @proxy;
            expires       24h;
            add_header    Cache-Control  private;

        }
        location ~* ^.+\.(shtml|shtm)$ {
            access_log  /var/log/nginx/ssi.access_log;
            error_log   /var/log/nginx/ssi.error_log;
	    ssi on;
            root   /www/static/$host;
            try_files $uri @proxy;
        }

        location ~* ^.+\.(php|html|htm)$ {
            proxy_pass  http://'$lo';
	    ssi on;
            limit_req zone=html burst=30  nodelay;
            #proxy_cache cache;
        }

        location ~* ^favicon.ico|robots.txt$ {
            root   /www/static/$host;
            try_files $uri @proxy;
        }

        location =/ {
            proxy_pass  http://'$lo';
	    ssi on;
            #proxy_cache cache;
            limit_req zone=one burst=5  nodelay;
        }

        location ~* ^.+\.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|wav|bmp|rtf|js|avi|js|mov|mpeg|mpg|mp3|swf|vob|xml|3gp|torrent)$ {
            root   /www/static/$host;
	    ssi on;
            access_log  /var/log/nginx/static.access_log  combined buffer=64k;
            error_log   /var/log/nginx/static.error_log;
            try_files $uri @proxy;
            expires       24h;
            add_header    Cache-Control  private;

        }
        rewrite ^/awstats/$ /awstats/awstats.pl redirect;
    }








' > /etc/nginx/sites-enabled/000-default



echo '
#    open_file_cache          max=10000  inactive=120s;
#    open_file_cache_valid    60s;
#    open_file_cache_min_uses 2;
#    open_file_cache_errors   on;
' > /etc/nginx/conf.d/open_file.conf
echo '
    reset_timedout_connection on;
    server_tokens off;
    tcp_nopush on;
    gzip_min_length     1100;
    gzip_buffers        4 8k;
' > /etc/nginx/conf.d/system.conf

echo '
limit_req_zone  $binary_remote_addr  zone=html:10m rate=10r/s;
limit_req_zone  $binary_remote_addr  zone=one:10m   rate=1r/s ;
' > /etc/nginx/conf.d/limit.conf



echo '
    proxy_redirect     off;
    proxy_set_header   Host             $host;
    proxy_set_header   X-Real-IP        $remote_addr;
    proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    client_max_body_size       10m;
    client_body_buffer_size    128k;
    proxy_connect_timeout      500;
    proxy_send_timeout         500;
    proxy_read_timeout         500;
    proxy_buffer_size          8k;
    proxy_buffers              4 64k;
    proxy_busy_buffers_size    64k;
    proxy_temp_file_write_size 64k;
    proxy_cache_path  /www/cache/  levels=1:2   keys_zone=cache:1m  max_size=1000m;
    proxy_cache_key  "$host$request_uri$is_args$args";
    proxy_cache_valid  any 15m;
' > /etc/nginx/conf.d/proxy.conf

mkdir -p /www/cache
rm -f /etc/logrotate.d/nginx-catap
chown www-data /www/cache
killall -9 nginx
nginx




