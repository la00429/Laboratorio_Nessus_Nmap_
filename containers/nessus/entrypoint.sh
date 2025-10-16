#!/bin/bash

# Script de inicio para Nessus
echo "=== Iniciando Nessus Vulnerability Scanner ==="
echo "Nessus Container - IP: 10.10.0.100"
echo "=============================================="

# Configurar variables
export NESSUS_HOME=/opt/nessus
export PATH=$NESSUS_HOME/bin:$PATH

# Verificar instalación
echo "Verificando instalación de Nessus..."
if [ -f "$NESSUS_HOME/sbin/nessusd" ]; then
    echo "✓ Nessus instalado correctamente"
else
    echo "⚠ Nessus no encontrado, intentando instalación..."
    /init-nessus.sh
fi

# Verificar conectividad
echo "Verificando conectividad de red..."
ping -c 1 10.10.0.1 > /dev/null 2>&1 && echo "✓ Gateway accesible" || echo "⚠ Gateway no accesible"

# Mostrar información
echo ""
echo "Información del contenedor:"
echo "- Hostname: $(hostname)"
echo "- IP: $(hostname -i)"
echo "- Usuario: $(whoami)"
echo "- Directorio Nessus: $NESSUS_HOME"
echo ""

# Verificar servicios objetivo
echo "Verificando servicios objetivo..."
for target in 10.10.0.20 10.10.0.21 10.10.0.30; do
    ping -c 1 -W 1 $target > /dev/null 2>&1 && echo "✓ $target accesible" || echo "⚠ $target no accesible"
done

echo ""
echo "Nessus estará disponible en:"
echo "- Web UI: https://10.10.0.100:8834"
echo "- Desde host: https://localhost:8834"
echo ""
echo "Credenciales por defecto:"
echo "- Usuario: admin"
echo "- Contraseña: $NESSUS_ADMIN_PASSWORD"
echo ""

# Iniciar Nessus
echo "Iniciando servicio Nessus..."
exec "$@"
