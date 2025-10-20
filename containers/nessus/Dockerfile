FROM ubuntu:22.04

# Metadatos
LABEL maintainer="Laboratorio Nmap+Nessus"
LABEL description="Nessus Vulnerability Scanner Simulator"

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV NESSUS_ADMIN_PASSWORD=admin123
ENV NESSUS_HOME=/opt/nessus

# Actualizar sistema e instalar dependencias
RUN apt-get update && apt-get install -y \
    apache2 \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios y archivos como root
RUN mkdir -p /opt/nessus/sbin && \
    mkdir -p /opt/nessus/www

# Crear simulador de Nessus
RUN echo '#!/bin/bash' > /opt/nessus/sbin/nessusd && \
    echo 'echo "=== Nessus Simulator ==="' >> /opt/nessus/sbin/nessusd && \
    echo 'echo "Simulador de Nessus para laboratorio educativo"' >> /opt/nessus/sbin/nessusd && \
    echo 'echo "Web UI disponible en: https://localhost:8834"' >> /opt/nessus/sbin/nessusd && \
    echo 'echo "Usuario: admin"' >> /opt/nessus/sbin/nessusd && \
    echo 'echo "Password: admin123"' >> /opt/nessus/sbin/nessusd && \
    echo 'echo "Servidor iniciado en modo simulación..."' >> /opt/nessus/sbin/nessusd && \
    echo 'while true; do sleep 30; done' >> /opt/nessus/sbin/nessusd && \
    chmod +x /opt/nessus/sbin/nessusd

RUN echo '#!/bin/bash' > /opt/nessus/sbin/nessuscli && \
    echo 'echo "Nessus CLI Simulator - Comando: $@"' >> /opt/nessus/sbin/nessuscli && \
    echo 'echo "Simulador ejecutando comando: $@"' >> /opt/nessus/sbin/nessuscli && \
    chmod +x /opt/nessus/sbin/nessuscli

# Crear página web simulada de Nessus
RUN echo '<html><head><title>Nessus Simulator</title></head>' > /opt/nessus/www/index.html && \
    echo '<body style="font-family: Arial, sans-serif; margin: 50px; background-color: #f0f0f0;">' >> /opt/nessus/www/index.html && \
    echo '<div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">' >> /opt/nessus/www/index.html && \
    echo '<h1 style="color: #2c5aa0;">Nessus Vulnerability Scanner</h1>' >> /opt/nessus/www/index.html && \
    echo '<h2 style="color: #666;">Simulador para Laboratorio Educativo</h2>' >> /opt/nessus/www/index.html && \
    echo '<p>Este es un simulador de Nessus para propósitos educativos del laboratorio.</p>' >> /opt/nessus/www/index.html && \
    echo '<p>En un entorno real, aquí verías la interfaz web completa de Nessus.</p>' >> /opt/nessus/www/index.html && \
    echo '<hr>' >> /opt/nessus/www/index.html && \
    echo '<h3>Credenciales de Acceso:</h3>' >> /opt/nessus/www/index.html && \
    echo '<ul>' >> /opt/nessus/www/index.html && \
    echo '<li><strong>Usuario:</strong> admin</li>' >> /opt/nessus/www/index.html && \
    echo '<li><strong>Contraseña:</strong> admin123</li>' >> /opt/nessus/www/index.html && \
    echo '<li><strong>Puerto:</strong> 8834</li>' >> /opt/nessus/www/index.html && \
    echo '</ul>' >> /opt/nessus/www/index.html && \
    echo '<hr>' >> /opt/nessus/www/index.html && \
    echo '<h3>Funcionalidades del Simulador:</h3>' >> /opt/nessus/www/index.html && \
    echo '<ul>' >> /opt/nessus/www/index.html && \
    echo '<li>Interfaz web simulada</li>' >> /opt/nessus/www/index.html && \
    echo '<li>Integración con scripts de Nmap</li>' >> /opt/nessus/www/index.html && \
    echo '<li>Ejercicios de laboratorio</li>' >> /opt/nessus/www/index.html && \
    echo '</ul>' >> /opt/nessus/www/index.html && \
    echo '</div>' >> /opt/nessus/www/index.html && \
    echo '</body></html>' >> /opt/nessus/www/index.html

# Configurar Apache para servir la página simulada CON PERMISOS CORRECTOS
RUN echo 'Listen 8834' >> /etc/apache2/ports.conf && \
    echo '<VirtualHost *:8834>' >> /etc/apache2/sites-available/nessus.conf && \
    echo '    DocumentRoot /opt/nessus/www' >> /etc/apache2/sites-available/nessus.conf && \
    echo '    ServerName localhost' >> /etc/apache2/sites-available/nessus.conf && \
    echo '    <Directory /opt/nessus/www>' >> /etc/apache2/sites-available/nessus.conf && \
    echo '        Options Indexes FollowSymLinks' >> /etc/apache2/sites-available/nessus.conf && \
    echo '        AllowOverride None' >> /etc/apache2/sites-available/nessus.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/nessus.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/nessus.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/nessus.conf && \
    a2ensite nessus.conf

# Configurar permisos correctos
RUN chown -R www-data:www-data /opt/nessus/www && \
    chmod -R 755 /opt/nessus/www

# Crear usuario nessus después de crear los archivos
RUN groupadd -r nessus && useradd -r -g nessus -d /opt/nessus -s /bin/bash nessus && \
    chown -R nessus:nessus /opt/nessus

# Crear script de inicialización
COPY containers/nessus/init-nessus.sh /init-nessus.sh
RUN chmod +x /init-nessus.sh

# Crear script de entrada
COPY containers/nessus/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

# Exponer puertos
EXPOSE 8834

# Volúmenes
VOLUME ["/opt/nessus/var", "/opt/nessus/plugins", "/opt/nessus/imports"]

# Usuario
USER nessus

# Punto de entrada
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/nessus/sbin/nessusd", "-D"]