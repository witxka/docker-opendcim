#name of container: docker-opendcim
#versison of container: 0.2.1
FROM quantumobject/docker-baseimage:15.04
MAINTAINER Angel Rodriguez  "angelrr7702@gmail.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-backports main restricted " >> /etc/apt/sources.list
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q php5 snmp \
                    php5-snmp \
                    snmp-mibs-downloader \
                    php5-curl \
                    php-gettext\
                    mysql-server \
                    php5-mysql \
                    apache2-utils \
                    graphviz \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*

# to add mysqld deamon to runit
RUN mkdir /etc/service/mysqld
COPY mysqld.sh /etc/service/mysqld/run
RUN chmod +x /etc/service/mysqld/run

# to add apache2 deamon to runit
RUN mkdir /etc/service/apache2
COPY apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

#some configuration for apache
COPY apache2.conf /etc/apache2/apache2.conf
RUN sed  -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/dcim/' /etc/apache2/sites-available/default-ssl.conf

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf
    
##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convination of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups

#script to execute after install configuration done .... 
COPY after_install.sh /sbin/after_install
RUN chmod +x /sbin/after_install

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 443

#creatian of volume 
VOLUME /var/www/

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
