#!/bin/bash

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld /var/lib/mysql
chpst -u mysql /usr/sbin/mysqld --initialize --skip-grant-tables &
sleep 2s
password=$(cat /var/log/mysql/error.log | grep "A temporary password is generated for" | tail -1 | sed -n 's/.*root@localhost: //p')

 mysql -uroot -p$password -Bse "ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysqlpsswd';"
 #mysqladmin -u root password mysqlpsswd
 mysqladmin -u root -pmysqlpsswd reload
 mysqladmin -u root -pmysqlpsswd create dcim

 echo "GRANT ALL ON dcim.* TO dcim@localhost IDENTIFIED BY 'dcim'; flush privileges; " | mysql -u root -pmysqlpsswd
 echo "SET GLOBAL sql_mode = '';" | mysql -u root -pmysqlpsswd

 cd /var/www
 wget http://opendcim.org/packages/openDCIM-4.5.tar.gz
 tar zxpvf openDCIM-4.5.tar.gz
 ln -s openDCIM-4.5 dcim
 rm openDCIM-4.5.tar.gz
 rm -R /var/www/html
 chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings /var/www/dcim/vendor/mpdf/mpdf/ttfontdata
 
 cd /var/www/dcim
 cp db.inc.php-dist db.inc.php
 
 #to fix error relate to ip address of container apache2
 echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
 ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf
 
 #  copy conf of 
 cat << EOF > /var/www/dcim/.htaccess
AuthType Basic
AuthName "openDCIM"
AuthUserFile /var/www/opendcim.password
Require valid-user
EOF
 
 htpasswd -cb /var/www/opendcim.password dcim dcim
 a2enmod rewrite

killall mysqld
sleep 5s
