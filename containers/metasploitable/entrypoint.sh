#!/bin/bash

# Script de inicio para Metasploitable2
echo "=== Iniciando Metasploitable2 ==="
echo "Metasploitable Container - IP: 10.10.0.20"
echo "=========================================="

# Configurar variables
export DEBIAN_FRONTEND=noninteractive

# Iniciar servicios
echo "Iniciando servicios vulnerables..."

# Iniciar SSH
service ssh start && echo "✓ SSH iniciado (puerto 22)"

# Iniciar FTP
service vsftpd start && echo "✓ FTP iniciado (puerto 21)"

# Iniciar Apache
service apache2 start && echo "✓ Apache iniciado (puerto 80)"

# Iniciar MySQL
service mysql start && echo "✓ MySQL iniciado (puerto 3306)"

# Iniciar PostgreSQL
service postgresql start && echo "✓ PostgreSQL iniciado (puerto 5432)"

# Iniciar xinetd para servicios adicionales
service xinetd start && echo "✓ xinetd iniciado"

# Mostrar información
echo ""
echo "Información del contenedor:"
echo "- Hostname: $(hostname)"
echo "- IP: $(hostname -i)"
echo "- Usuario root: password"
echo "- Usuario msfadmin: msfadmin"
echo ""

echo "Servicios vulnerables disponibles:"
echo "- SSH (22): root/password, msfadmin/msfadmin"
echo "- FTP (21): anonymous, root/password"
echo "- Telnet (23): root/password"
echo "- SMTP (25): Postfix"
echo "- DNS (53): BIND9"
echo "- HTTP (80): Apache2"
echo "- MySQL (3306): msf/msf"
echo "- PostgreSQL (5432): msf/msf"
echo ""

echo "¡ADVERTENCIA! Este sistema contiene vulnerabilidades intencionadas."
echo "Solo usar en entornos de laboratorio aislados."
echo ""

# Mantener el contenedor corriendo
exec "$@"
