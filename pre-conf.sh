#!/bin/bash

/usr/bin/mysqld_safe &
 sleep 5s

 mysqladmin -u root password mysqlpsswd
 mysqladmin -u root -pmysqlpsswd reload
 mysqladmin -u root -pmysqlpsswd create drupal

 echo "GRANT ALL ON drupal.* TO drupaluser@localhost IDENTIFIED BY 'drupaldbpasswd'; flush privileges; " | mysql -u root -pmysqlpsswd

 wget 
 
 rm -R /var/www/html
 
 #to fix error relate to ip address of container apache2
 echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
 ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf
 
 #  copy conf of 

 a2enmod rewrite
 
killall mysqld
sleep 5s
