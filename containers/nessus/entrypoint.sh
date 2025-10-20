#!/bin/bash
set -e

clear
echo "=========================================="
echo "=== NESSUS VULNERABILITY SCANNER REAL ==="
echo "=========================================="
echo ""
echo "Sistema: Ubuntu 22.04 LTS"
echo "Container IP: 10.10.0.100"
echo "Web UI: https://localhost:8834"
echo "=========================================="
echo ""

# Verificar si Nessus está instalado
if [ -f "/opt/nessus/sbin/nessusd" ]; then
    echo "✅ Nessus instalado correctamente"
    echo ""
    
    # Verificar versión
    NESSUS_VERSION=$(/opt/nessus/sbin/nessusd -v 2>/dev/null || echo "Versión no disponible")
    echo "📦 Versión: $NESSUS_VERSION"
    echo ""
    
    # Verificar si ya está inicializado
    if [ ! -f "/opt/nessus/var/nessus/.initialized" ]; then
        echo "⚙️  PRIMERA VEZ - CONFIGURACIÓN INICIAL"
        echo "=========================================="
        echo ""
        echo "PASOS PARA CONFIGURAR NESSUS:"
        echo ""
        echo "1. Abre tu navegador en: https://localhost:8834"
        echo ""
        echo "2. Acepta el certificado SSL"
        echo "   (Haz clic en 'Avanzado' > 'Continuar a localhost')"
        echo ""
        echo "3. Selecciona 'Nessus Essentials' (GRATIS)"
        echo ""
        echo "4. Crea un usuario administrador:"
        echo "   - Usuario: admin"
        echo "   - Contraseña: admin123"
        echo "   - Email: tu email"
        echo ""
        echo "5. Obtén código de activación GRATIS:"
        echo "   https://www.tenable.com/products/nessus/nessus-essentials"
        echo "   (Recibirás: XXXX-XXXX-XXXX-XXXX-XXXX)"
        echo ""
        echo "6. Ingresa el código en Nessus"
        echo ""
        echo "7. Espera descarga de plugins (10-30 minutos)"
        echo "   Nota: ¡No cierres el navegador!"
        echo ""
        echo "=========================================="
        touch /opt/nessus/var/nessus/.initialized
    fi
    
    # Verificar si Nessus ya está corriendo
    if pgrep -f nessusd > /dev/null 2>&1; then
        echo "ℹ️  Nessus ya está ejecutándose"
    else
        # Iniciar Nessus
        echo "🚀 Iniciando servicio Nessus..."
        /opt/nessus/sbin/nessusd > /dev/null 2>&1 &
        
        # Esperar a que Nessus esté listo
        echo "⏳ Esperando a que Nessus esté listo..."
        sleep 8
    fi
    
    # Verificar si el servicio está corriendo
    if pgrep -f nessusd > /dev/null 2>&1; then
        echo ""
        echo "=========================================="
        echo "✅ NESSUS ESTÁ EJECUTÁNDOSE"
        echo "=========================================="
        echo ""
        echo "🌐 ACCESO WEB:"
        echo "   https://localhost:8834"
        echo "   http://10.10.0.100:8834 (redirige a HTTPS)"
        echo ""
        echo "👤 CREDENCIALES RECOMENDADAS:"
        echo "   Usuario: admin"
        echo "   Contraseña: admin123"
        echo ""
        echo "🎯 OBJETIVOS DEL LABORATORIO:"
        echo "   10.10.0.20 - Metasploitable (SSH: msfadmin/msfadmin)"
        echo "   10.10.0.21 - DVWA (Web: admin/password)"
        echo "   10.10.0.30 - Windows Target"
        echo ""
        echo "📚 AYUDA:"
        echo "   /opt/nessus/help.sh"
        echo ""
        echo "=========================================="
    else
        echo ""
        echo "⚠️  Nessus no se inició correctamente"
        echo "Intenta iniciar manualmente:"
        echo "   docker exec nessus-lab /opt/nessus/sbin/nessusd"
        echo ""
    fi
else
    echo "❌ NESSUS NO ESTÁ INSTALADO"
    echo "=========================================="
    echo ""
    echo "📖 INSTRUCCIONES DE INSTALACIÓN:"
    echo ""
    echo "1. Descarga Nessus desde:"
    echo "   https://www.tenable.com/downloads/nessus"
    echo "   Archivo: Nessus-10.x.x-ubuntu1404_amd64.deb"
    echo ""
    echo "2. Usa el script de instalación:"
    echo "   .\\scripts\\install_nessus_real.ps1 manual Nessus-*.deb"
    echo ""
    echo "   O manualmente:"
    echo "   docker cp Nessus-*.deb nessus-lab:/tmp/"
    echo "   docker exec nessus-lab dpkg -i /tmp/Nessus-*.deb"
    echo "   docker exec nessus-lab apt-get install -f -y"
    echo ""
    echo "3. Reinicia el contenedor:"
    echo "   docker-compose restart nessus"
    echo ""
    echo "=========================================="
fi

# Verificar conectividad con objetivos
echo ""
echo "🔍 VERIFICANDO CONECTIVIDAD CON OBJETIVOS:"
for ip in 10.10.0.20 10.10.0.21 10.10.0.30; do
    if ping -c 1 -W 1 $ip > /dev/null 2>&1; then
        echo "   ✅ $ip - Accesible"
    else
        echo "   ❌ $ip - No accesible"
    fi
done

echo ""
echo "📝 COMANDOS ÚTILES:"
echo "   Ver logs: docker logs -f nessus-lab"
echo "   Acceder: docker exec -it nessus-lab bash"
echo "   Estado: docker exec nessus-lab ps aux | grep nessusd"
echo ""
echo "=========================================="
echo "✓ Contenedor iniciado y listo"
echo "=========================================="
echo ""

# Mantener contenedor vivo
tail -f /dev/null