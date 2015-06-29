#!/bin/bash
#remove the install script and create another password for dcim

rm /var/www/dcim/install.php
echo "To change default password for dcim user:"
htpasswd  /var/www/opendcim.password dcim
