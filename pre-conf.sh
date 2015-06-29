#!/bin/bash

/usr/bin/mysqld_safe &
 sleep 5s

 mysqladmin -u root password mysqlpsswd
 mysqladmin -u root -pmysqlpsswd reload
 mysqladmin -u root -pmysqlpsswd create dcim

 echo "GRANT ALL ON dcim.* TO dcim@localhost IDENTIFIED BY 'dcim'; flush privileges; " | mysql -u root -pmysqlpsswd

 cd /var/www
 wget http://opendcim.org/packages/openDCIM-4.0a.tar.gz
 tar zxpvf openDCIM-4.0a.tar.gz
 ln -s openDCIM-4.0a dcim
 rm openDCIM-4.0a.tar.gz
 rm -R /var/www/html
 chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings
 
 cd /var/www/dcim
 cp db.inc.php-dist db.inc.php
 
 #to fix error relate to ip address of container apache2
 echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
 ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf
 
 #  copy conf of 
 cat << EOF > /var/www/dcim/.htaccess
AuthType Basic
AuthName "openDCIM"
AuthUserFile /var/www/opendcim.password
Require valid-user
EOF
 
 
 htpasswd -cb /var/www/opendcim.password dcim dcim
 a2enmod ssl
 a2enmod rewrite
 a2ensite default-ssl

killall mysqld
sleep 5s
