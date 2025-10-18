#!/bin/bash

# Script de inicio para el contenedor Kali Linux
echo "=== Iniciando Laboratorio Nmap + Nessus ==="
echo "Kali Linux Container - IP: 10.10.0.10"
echo "=========================================="

# Configurar variables de entorno
export DISPLAY=${DISPLAY:-:0}

# Verificar conectividad de red
echo "Verificando conectividad de red..."
nmap -sn 10.10.0.1 > /dev/null 2>&1 && echo "✓ Gateway accesible" || echo "⚠ Gateway no accesible"

# Mostrar información del contenedor
echo ""
echo "Información del contenedor:"
echo "- Hostname: $(hostname)"
echo "- IP: $(hostname -i)"
echo "- Usuario: $(whoami)"
echo "- Directorio de trabajo: $(pwd)"
echo ""

# Mostrar herramientas disponibles
echo "Herramientas disponibles:"
echo "- Nmap: $(nmap --version | head -1)"
echo "- Python: $(python3 --version)"
echo "- SSH: $(ssh -V 2>&1)"
echo ""

# Verificar servicios objetivo
echo "Verificando servicios objetivo..."
for target in 10.10.0.20 10.10.0.21 10.10.0.30 10.10.0.100; do
    nmap -sn $target > /dev/null 2>&1 && echo "✓ $target accesible" || echo "⚠ $target no accesible"
done

echo ""
echo "Laboratorio listo. Puedes acceder via SSH:"
echo "ssh root@localhost -p 2222 (password: kali123)"
echo "ssh labuser@localhost -p 2222 (password: lab123)"
echo ""
echo "Comandos útiles:"
echo "- nmap -sn 10.10.0.0/24  # Descubrir hosts"
echo "- nmap -sS -sV 10.10.0.20  # Escanear Metasploitable"
echo ""

# Mantener el contenedor corriendo
exec "$@"
