#!/usr/bin/env bash
$PASSWORD = 'mypass';


sudo apt-get -y update
sudo apt-get -y upgrade

# nginx
sudo apt-get -y install nginx

# set up nginx server
sudo rm /etc/nginx/sites-available/default
sudo ln -s /vagrant/provision/nginx/default /etc/nginx/sites-available/default

sudo service nginx restart

#install php
sudo apt-get -y install php5-common php5-mysqlnd php5-xmlrpc php5-curl php5-gd php5-cli php5-fpm php-pear php5-dev php5-imap php5-mcrypt 

sudo rm /etc/php5/fpm/php.ini
sudo ln -s /vagrant/provision/php-fpm/php.ini /etc/php5/fpm/php.ini

sudo service php5-fpm reload

#install mysql
sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server php5-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect nginx"
sudo apt-get -y install phpmyadmin


#finish up
sudo service nginx restart

# install git
sudo apt-get -y install git

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer