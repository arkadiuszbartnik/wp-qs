FROM php:8.2-apache

# Install necessary PHP extensions
RUN apt-get clean && \
    apt-get update && \
    (apt-get install -y --no-install-recommends --fix-missing \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    curl \
    less \
    git \
    || (apt-get update && apt-get install -y --no-install-recommends --fix-missing \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    curl \
    less \
    git)) \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo_mysql \
    zip \
    mbstring \
    xml \
    soap \
    bcmath \
    exif

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Enable mod_rewrite for Apache
RUN a2enmod rewrite

# Download WordPress (latest version)
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && mv wordpress/* /var/www/html/ \
    && rm -rf wordpress latest.tar.gz

# Copy WordPress configuration (if exists)
COPY config/wp-config.php /var/www/html/wp-config.php

# Note: wp-content (plugins, themes, uploads) is mounted as a volume in docker-compose.yml
# This allows for live development where changes in local filesystem are immediately reflected

# Set file ownership
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/

# Create wp-content/uploads directory if it doesn't exist
RUN mkdir -p /var/www/html/wp-content/uploads
RUN chown -R www-data:www-data /var/www/html/wp-content/uploads

# Set port
EXPOSE 80

# Run Apache
CMD ["apache2-foreground"]
