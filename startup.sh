#!/bin/bash


set -e

#in case Volume are empty
if [ "$(ls -A /var/lib/mysql)" ]; then
    echo "mysql folder with data"    
else
    cp -Rp /var/backup/mysql/* /var/lib/mysql/ 
    chown mysql:mysql /var/lib/mysql
fi

if [ "$(ls -A /var/www/dcim/pictures)" ]; then
   echo "pictures folder with data"
else
    cp -Rp /var/backup/pictures/* /var/www/dcim/pictures/
    chown www-data:www-data /var/www/dcim/pictures
fi

if [ "$(ls -A /var/www/dcim/drawings)" ]; then
   echo "drawings folder with data"
else
    cp -Rp /var/backup/drawings/* /var/www/dcim/drawings/
    chown www-data:www-data /var/www/dcim/drawings
fi


if [ -f /etc/configured ]; then
        echo 'already configured'
else
       
        #needed to fix problem with ubuntu ... and cron 
        update-locale
        date > /etc/configured
fi
