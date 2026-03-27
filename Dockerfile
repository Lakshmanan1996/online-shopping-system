FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP, MySQL
RUN apt update && apt install -y \
    apache2 \
    php \
    php-mysql \
    mysql-server \
    curl \
    unzip

# Enable Apache mods
RUN a2enmod rewrite

# Copy project
COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# MySQL setup
RUN service mysql start && \
    mysql -e "CREATE DATABASE shopping;" && \
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Expose ports
EXPOSE 80 3306

# Start both services
CMD service mysql start && apachectl -D FOREGROUND
