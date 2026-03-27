# Use official PHP with Apache
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Copy project files to Apache directory
COPY . /var/www/html/

# Install required PHP extensions
RUN docker-php-ext-install mysqli

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80
