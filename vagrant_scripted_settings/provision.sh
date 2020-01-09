#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='mypass'

# create project folder
sudo mkdir "/var/www/"

# update / upgrade
sudo apt update
sudo apt -y upgrade

sudo apt install -y ca-certificates apt-transport-https
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt update
sudo apt install -y php7.3
sudo apt install -y php7.3-cli php7.3-common php7.3-curl php7.3-mbstring php7.3-mysql php7.3-xml php7.3-zip php7.3-Intl php7.3-mysqli

sudo apt install -y php7.2
sudo apt install -y php7.2-cli php7.2-common php7.2-curl php7.2-mbstring php7.2-mysql php7.2-xml php7.2-zip php7.2-Intl php7.2-mysqli

sudo apt install -y php7.1
sudo apt install -y php7.1-cli php7.1-common php7.1-curl php7.1-mbstring php7.1-mysql php7.1-xml php7.1-zip php7.1-Intl php7.1-mysqli

sudo apt install -y mysql-server

sudo apt install -y apache2 libapache2-mod-php7.1 libapache2-mod-php7.2 libapache2-mod-php7.3

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt install -y phpmyadmin php-mbstring php-gettext

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www"
    <Directory "/var/www">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)

mkdir serverconfig
touch /serverconfig/vhosts.conf

sudo ln -s /etc/apache2/sites-enabled/000-default.conf /serverconfig/vhosts.conf

sudo echo "${VHOST}" > /serverconfig/vhosts.conf

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
sudo service apache2 restart

#make posible changin the php version
sudo apt install -y software-properties-common

# install git
sudo apt -y install git

# install Composer
cd /var/www && curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
