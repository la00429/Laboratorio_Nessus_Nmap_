FROM ubuntu:20.04

# Metadatos
LABEL maintainer="Laboratorio Nmap+Nessus"
LABEL description="DVWA - Damn Vulnerable Web Application"

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=dvwa
ENV MYSQL_USER=dvwa
ENV MYSQL_PASSWORD=p@ssw0rd

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    # Servidor web y PHP
    apache2 \
    php \
    php-mysql \
    php-gd \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    libapache2-mod-php \
    # Servidor MySQL
    mysql-server \
    mysql-client \
    # Herramientas adicionales
    wget \
    unzip \
    curl \
    # Limpieza
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar MySQL
RUN service mysql start && \
    mysql -e "CREATE DATABASE IF NOT EXISTS dvwa;" && \
    mysql -e "CREATE USER IF NOT EXISTS 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';" && \
    mysql -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Descargar e instalar DVWA
RUN cd /var/www/html && \
    wget -q https://github.com/digininja/DVWA/archive/master.zip && \
    unzip master.zip && \
    mv DVWA-master/* . && \
    rm -rf DVWA-master master.zip

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Configurar PHP
RUN echo "allow_url_include=On" >> /etc/php/7.4/apache2/php.ini && \
    echo "allow_url_fopen=On" >> /etc/php/7.4/apache2/php.ini && \
    echo "safe_mode=Off" >> /etc/php/7.4/apache2/php.ini && \
    echo "magic_quotes_gpc=Off" >> /etc/php/7.4/apache2/php.ini && \
    echo "display_errors=On" >> /etc/php/7.4/apache2/php.ini

# Configurar Apache
RUN a2enmod rewrite && \
    echo "<Directory /var/www/html>" >> /etc/apache2/apache2.conf && \
    echo "    AllowOverride All" >> /etc/apache2/apache2.conf && \
    echo "</Directory>" >> /etc/apache2/apache2.conf

# Crear configuración de DVWA
COPY containers/dvwa/config/config.inc.php /var/www/html/config/config.inc.php

# Script de inicio
COPY containers/dvwa/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

# Exponer puertos
EXPOSE 80 3306

# Punto de entrada
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
