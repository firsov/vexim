<VirtualHost *:80>
    DocumentRoot %home% 
    ServerName %dom%
    ServerAlias www.%dom%
     <Directory "%home%">
        AllowOverride All
     </Directory>
   AssignUserID %usr% %usr%
   CustomLog /www/%usr%/%dom%/log/access.log combined
   ErrorLog /www/%usr%/%dom%/log/error.log
   php_value session.save_path  "/www/%usr%/%dom%/tmp"
   php_value upload_tmp_dir  "/www/%usr%/%dom%/tmp"
</VirtualHost>
