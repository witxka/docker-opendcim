#!/bin/bash

/usr/bin/mysqld_safe  &
sleep 2s
opendcim_version=20.02
 mysqladmin -u root password mysqlpsswd
 mysqladmin -u root -pmysqlpsswd reload
 mysqladmin -u root -pmysqlpsswd create dcim

 echo "GRANT ALL ON dcim.* TO dcim@localhost IDENTIFIED BY 'dcim'; flush privileges; " | mysql -u root -pmysqlpsswd
 echo "SET GLOBAL sql_mode = '';" | mysql -u root -pmysqlpsswd

 cd /var/www
 wget --no-check-certificate http://opendcim.org/packages/openDCIM-${opendcim_version}.tar.gz
 tar zxpvf openDCIM-${opendcim_version}.tar.gz
 mv openDCIM-${opendcim_version} dcim
 rm openDCIM-${opendcim_version}.tar.gz
 rm -R /var/www/html
 mkdir -p /var/www/dcim/assets/pictures
 mkdir -p /var/www/dcim/assets/drawings
 chmod g+w /var/www/dcim/assets/pictures /var/www/dcim/assets/drawings
 chgrp -R www-data /var/www/dcim/assets/pictures /var/www/dcim/assets/drawings /var/www/dcim/vendor/mpdf/mpdf/ttfontdata

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

#make backup copy for Volume 
mkdir -p /var/backup
cp -Rp /var/lib/mysql /var/backup
cp -Rp /var/www/dcim/assets/pictures /var/backup
cp -Rp /var/www/dcim/assets/drawings /var/backup
