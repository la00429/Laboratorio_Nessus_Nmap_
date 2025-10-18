#!/bin/bash
set -e

echo "=== Iniciando Nessus Vulnerability Scanner ==="
echo "Nessus Container - IP: 10.10.0.100"
echo "=============================================="

# Verificar si los archivos del simulador existen
if [ ! -f "/opt/nessus/sbin/nessusd" ]; then
    echo "Creando simulador de Nessus..."
    mkdir -p /opt/nessus/sbin /opt/nessus/www
    
    # Crear simulador de Nessus
    cat > /opt/nessus/sbin/nessusd << 'EOF'
#!/bin/bash
echo "=== Nessus Simulator ==="
echo "Simulador de Nessus para laboratorio educativo"
echo "Web UI disponible en: https://localhost:8834"
echo "Usuario: admin"
echo "Password: admin123"
echo "Servidor iniciado en modo simulación..."
echo "Para acceder a la interfaz web, visite: http://localhost:8834"
while true; do sleep 30; done
EOF
    chmod +x /opt/nessus/sbin/nessusd

    # Crear simulador CLI
    cat > /opt/nessus/sbin/nessuscli << 'EOF'
#!/bin/bash
echo "Nessus CLI Simulator - Comando: $@"
echo "Simulador ejecutando comando: $@"
EOF
    chmod +x /opt/nessus/sbin/nessuscli

    # Crear página web simulada
    mkdir -p /opt/nessus/www
    cat > /opt/nessus/www/index.html << 'EOF'
<html><head><title>Nessus Simulator</title></head>
<body style="font-family: Arial, sans-serif; margin: 50px; background-color: #f0f0f0;">
<div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
<h1 style="color: #2c5aa0;">Nessus Vulnerability Scanner</h1>
<h2 style="color: #666;">Simulador para Laboratorio Educativo</h2>
<p>Este es un simulador de Nessus para propósitos educativos del laboratorio.</p>
<p>En un entorno real, aquí verías la interfaz web completa de Nessus.</p>
<hr>
<h3>Credenciales de Acceso:</h3>
<ul>
<li><strong>Usuario:</strong> admin</li>
<li><strong>Contraseña:</strong> admin123</li>
<li><strong>Puerto:</strong> 8834</li>
</ul>
<hr>
<h3>Funcionalidades del Simulador:</h3>
<ul>
<li>Interfaz web simulada</li>
<li>Integración con scripts de Nmap</li>
<li>Ejercicios de laboratorio</li>
</ul>
</div>
</body></html>
EOF
fi

echo "Verificando instalación de Nessus..."
if [ -f "/opt/nessus/sbin/nessusd" ]; then
    echo "✓ Simulador de Nessus encontrado"
else
    echo "⚠ Nessus no encontrado"
fi

echo "Verificando conectividad de red..."
if nmap -sn 10.10.0.1 >/dev/null 2>&1; then
    echo "✓ Gateway accesible"
else
    echo "⚠ Gateway no accesible"
fi

echo ""
echo "Información del contenedor:"
echo "- Hostname: $(hostname)"
echo "- IP: 10.10.0.100"
echo "- Usuario: nessus"
echo "- Directorio Nessus: /opt/nessus"
echo ""

echo "Verificando servicios objetivo..."
for ip in 10.10.0.20 10.10.0.21 10.10.0.30; do
    if nmap -sn $ip >/dev/null 2>&1; then
        echo "✓ $ip accesible"
    else
        echo "⚠ $ip no accesible"
    fi
done

echo ""
echo "Nessus estará disponible en:"
echo "- Web UI: https://10.10.0.100:8834"
echo "- Desde host: https://localhost:8834"
echo ""
echo "Credenciales por defecto:"
echo "- Usuario: admin"
echo "- Contraseña: admin123"
echo ""

echo "Iniciando servicio Nessus..."
exec "$@"