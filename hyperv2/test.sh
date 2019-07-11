#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
DB_DATA_PATH="/var/lib/mysql"
DB_ROOT_PASS="mypass"
DB_USER="admin"
DB_PASS="admin"
MAX_ALLOWED_PACKET="200M"

sudo apk update
sudo apk upgrade

sudo apk add  cifs-utils

#lamp instalation

sudo apk add --update --no-cache curl  php5-intl \
    php5-openssl \
    php5-dba \
    php5-sqlite3 \
    php5-pear \
    php5-phpdbg \
    php5-gmp \
    php5-pdo_mysql \
    php5-pcntl \
    php5-common \
    php5-xsl \
    php5-fpm \
    php5-mysql \
    php5-mysqli \
    php5-enchant \
    php5-pspell \
    php5-snmp \
    php5-doc \
    php5-dev \
    php5-xmlrpc \
    php5-embed \
    php5-xmlreader \
    php5-pdo_sqlite \
    php5-exif \
    php5-opcache \
    php5-ldap \
    php5-posix \
    php5-gd \
    php5-gettext \
    php5-json \
    php5-xml \
    php5 \
    php5-iconv \
    php5-sysvshm \
    php5-curl \
    php5-shmop \
    php5-odbc \
    php5-phar \
    php5-pdo_pgsql \
    php5-imap \
    php5-pdo_dblib \
    php5-pgsql \
    php5-pdo_odbc \
    php5-zip \
    php5-apache2 \
    php5-cgi \
    php5-ctype \
    php5-mcrypt \
    php5-wddx \
    php5-bcmath \
    php5-calendar \
    php5-dom \
    php5-sockets \
    php5-soap \
    php5-apcu \
    php5-sysvmsg \
    php5-zlib \
    php5-ftp \
    php5-sysvsem \
    php5-pdo \
    php5-bz2 \
    php5-mysqli \
    apache2 \
    php5-json \
    libxml2-dev \
    apache2-utils

#start apache2 on system open
sudo rc-update add apache2

#installing mariadb using the top settings
sudo apk add mariadb mariadb-client

# #Defining variables that will be used for setup and configuration
sudo mysql_install_db --user=mysql --datadir=${DB_DATA_PATH}
sudo rc-service mariadb start

# #Setting root password
sudo mysqladmin -u root password "${DB_ROOT_PASS}"

# #Creating new user, removing security sensitive data
echo "GRANT ALL ON *.* TO ${DB_USER}@'127.0.0.1' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;" > /tmp/sql
echo "GRANT ALL ON *.* TO ${DB_USER}@'localhost' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;" >> /tmp/sql
echo "GRANT ALL ON *.* TO ${DB_USER}@'::1' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;" >> /tmp/sql
echo "DELETE FROM mysql.user WHERE User='';" >> /tmp/sql
echo "DROP DATABASE test;" >> /tmp/sql
echo "FLUSH PRIVILEGES;" >> /tmp/sql
sudo cat /tmp/sql | mysql -u root --password="${DB_ROOT_PASS}"
sudo rm /tmp/sql

# #Modifying configuration file /etc/mysql/my.cnf
sudo sed -i "s|max_allowed_packet\s*=\s*1M|max_allowed_packet = ${MAX_ALLOWED_PACKET}|g" /etc/mysql/my.cnf
sudo sed -i "s|max_allowed_packet\s*=\s*16M|max_allowed_packet = ${MAX_ALLOWED_PACKET}|g" /etc/mysql/my.cnf

# #Normally you want to start the MariaDB server when the system is launching. This is done by adding MariaDB to the needed runlevel.
sudo rc-update add mariadb default

#install phpmyadmin
#Create a directory named webapps
sudo mkdir -p /usr/share/webapps/
#Download the source code
cd /usr/share/webapps
sudo wget http://files.directadmin.com/services/all/phpMyAdmin/phpMyAdmin-4.5.0.2-all-languages.tar.gz

#Unpack the archive and remove the archive
sudo tar zxvf phpMyAdmin-4.5.0.2-all-languages.tar.gz
sudo rm phpMyAdmin-4.5.0.2-all-languages.tar.gz

#Rename the folder
sudo mv phpMyAdmin-4.5.0.2-all-languages phpmyadmin

#Change the folder permissions
sudo chmod -R 777 /usr/share/webapps/

#Create a symlink to the phpmyadmin folder
# sudo ln -s /usr/share/webapps/phpmyadmin/ /var/www/localhost/htdocs/phpmyadmin
sudo cp /usr/share/webapps/phpmyadmin/ /var/www/localhost/htdocs/phpmyadmin


#install composer and git
sudo sudo apk add composer

sudo sudo apk add git

sudo rm -rf /var/cache/apk/*

sudo  rc-service apache2 restart
sudo rc-update add apache2