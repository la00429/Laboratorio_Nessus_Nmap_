#!/bin/bash

# Script de inicio para DVWA
echo "=== Iniciando DVWA ==="
echo "DVWA Container - IP: 10.10.0.21"
echo "================================"

# Iniciar MySQL
echo "Iniciando MySQL..."
service mysql start

# Esperar a que MySQL esté listo
echo "Esperando a que MySQL esté listo..."
while ! mysqladmin ping -h localhost --silent; do
    sleep 1
done
echo "✓ MySQL está listo"

# Configurar base de datos si no existe
echo "Configurando base de datos..."
mysql -e "CREATE DATABASE IF NOT EXISTS dvwa;" && echo "✓ Base de datos dvwa creada"
mysql -e "CREATE USER IF NOT EXISTS 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';" && echo "✓ Usuario dvwa creado"
mysql -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';" && echo "✓ Privilegios otorgados"
mysql -e "FLUSH PRIVILEGES;" && echo "✓ Privilegios aplicados"

# Configurar permisos
echo "Configurando permisos..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Mostrar información
echo ""
echo "Información del contenedor:"
echo "- Hostname: $(hostname)"
echo "- IP: $(hostname -i)"
echo "- Usuario: $(whoami)"
echo "- Base de datos: dvwa"
echo ""

echo "DVWA estará disponible en:"
echo "- Web UI: http://10.10.0.21"
echo "- Desde host: http://localhost:8180"
echo ""
echo "Credenciales por defecto:"
echo "- Usuario: admin"
echo "- Contraseña: password"
echo ""
echo "Base de datos MySQL:"
echo "- Host: localhost"
echo "- Usuario: dvwa"
echo "- Contraseña: p@ssw0rd"
echo "- Base de datos: dvwa"
echo ""

# Iniciar Apache
echo "Iniciando Apache..."
exec "$@"
