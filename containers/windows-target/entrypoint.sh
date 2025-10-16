#!/bin/bash

# Script de inicio para Windows Target Simulator
echo "=== Iniciando Windows Target Simulator ==="
echo "Windows Target Container - IP: 10.10.0.30"
echo "=========================================="

# Configurar variables
export WIN_PASSWORD=${WIN_PASSWORD:-Password123}

# Iniciar servicios
echo "Iniciando servicios..."

# Iniciar SSH
service ssh start && echo "✓ SSH iniciado (puerto 22)"

# Iniciar Samba
service smbd start && echo "✓ SMB/CIFS iniciado (puertos 139, 445)"
service nmbd start && echo "✓ NetBIOS iniciado"

# Iniciar xinetd
service xinetd start && echo "✓ xinetd iniciado"

# Mostrar información
echo ""
echo "Información del contenedor:"
echo "- Hostname: $(hostname)"
echo "- IP: $(hostname -i)"
echo "- Usuario administrator: $WIN_PASSWORD"
echo "- Usuario root: $WIN_PASSWORD"
echo ""

echo "Servicios disponibles:"
echo "- SSH (22): administrator/$WIN_PASSWORD, root/$WIN_PASSWORD"
echo "- SMB/CIFS (139, 445): administrator/$WIN_PASSWORD"
echo "- Telnet (23): root/$WIN_PASSWORD"
echo "- RPC (135): Simulado"
echo "- RDP (3389): Simulado"
echo "- SQL Server (1433): Simulado"
echo ""

echo "Recursos compartidos SMB:"
echo "- \\\\10.10.0.30\\homes (home directories)"
echo "- \\\\10.10.0.30\\shared (carpeta compartida)"
echo ""

echo "Para escaneos credentialed desde Nessus:"
echo "- Usuario: administrator"
echo "- Contraseña: $WIN_PASSWORD"
echo "- Dominio: (dejar vacío)"
echo ""

# Mantener el contenedor corriendo con supervisión de servicios
echo "Manteniendo servicios activos..."
while true; do
    # Verificar y reiniciar servicios si es necesario
    if ! pgrep -x "smbd" > /dev/null; then
        echo "Reiniciando SMB..."
        service smbd restart
    fi
    if ! pgrep -x "nmbd" > /dev/null; then
        echo "Reiniciando NetBIOS..."
        service nmbd restart
    fi
    if ! pgrep -x "sshd" > /dev/null; then
        echo "Reiniciando SSH..."
        service ssh restart
    fi
    sleep 30
done
