#!/bin/bash

echo 'This script should install and setup Wordpress'


# Variables needed for configurations

Dbname ='wordpress'
Dbuser ='wpuser'
Dbpass ='Techgrounds101'

###############
# nginx, mysql, WordPress.
# WordPress should have already configured with theme twentynineteen and with created user admin with password !2three456..
#####################


# install the needed packages
sudo apt update
sudo apt-get upgrade -y
sudo apt install nginx -y
sudo apt install mysql-server -y 
sudo apt install php7.4 php7.4-fpm php7.4-mysql php7.4-curl php7.4-gd php7.4-intl php7.4-mbstring php7.4-soap php7.4-xml php7.4-xmlrpc php7.4-zip 0 -y

#configure firewall nginx
sudo ufw enable
sudo ufw allow 'Nginx HTTP'

# install and configure mysql-server
sudo mysql -e "CREATE DATABASE $Dbname DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -e "CREATE USER '$Dbuser'@'localhost' IDENTIFIED BY '$Dbpass';"
sudo mysql -e "GRANT ALL ON $Dbname.* TO '$Dbuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure nginx to use the PHP Processor
# Cybergamerz can be changed to any domain name you want

cd /tmp
sudo wget -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sudo cp -a /tmp/wordpress/. /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress

cat << EOF > /etc/nginx/sites-available/wordpress
server {
	listen 80;
	server_name 10.0.2.15;

	root /var/www/wordpress;

	index index.html index.htm index.php;

	location / {
		try_files $uri $uri/ =404;
		try_files $uri $uri/ index.php$is_args$args;
	}

	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
	}

	location ~ /\.ht {
		deny all;
	}
}
EOF

sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default

cd /var/www/wordpress

sudo sed -i "s/'database_name_here'/'$Dbname'/g" wp-config.php
sudo sed -i "s/'username_here'/'$Dbuser'/g" wp-config.php
sudo sed -i "s/'password_here'/'$Dbpass'/g" wp-config.php

sudo systemctl restart nginx
sudo systemctl restart mysql


