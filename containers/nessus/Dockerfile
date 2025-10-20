FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NESSUS_HOME=/opt/nessus
ENV PATH="${PATH}:/opt/nessus/bin:/opt/nessus/sbin"

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    wget curl ca-certificates \
    iproute2 net-tools iputils-ping \
    vim nano procps \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios
RUN mkdir -p /opt/nessus/sbin /opt/nessus/var/nessus \
    /opt/nessus/lib/nessus/plugins /opt/nessus/imports

# Descargar e instalar Nessus automáticamente
# Usando una versión específica que permite descarga directa
RUN cd /tmp && \
    echo "Descargando Nessus..." && \
    wget --quiet --no-check-certificate \
    "https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.8.3-ubuntu1404_amd64.deb" \
    -O Nessus.deb 2>/dev/null || \
    wget --quiet --no-check-certificate \
    "https://www.tenable.com/downloads/api/v1/public/pages/nessus/downloads/23476/download?i_agree_to_tenable_license_agreement=true" \
    -O Nessus.deb 2>/dev/null || \
    echo "Descarga automática no disponible - instalación manual requerida" && \
    if [ -f Nessus.deb ] && [ -s Nessus.deb ]; then \
        echo "Instalando Nessus..." && \
        dpkg -i Nessus.deb && \
        apt-get install -f -y && \
        rm Nessus.deb && \
        echo "Nessus instalado correctamente"; \
    else \
        echo "No se pudo descargar Nessus automáticamente" && \
        rm -f Nessus.deb; \
    fi

# Crear script de entrypoint mejorado
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'echo "=========================================="' >> /entrypoint.sh && \
    echo 'echo "=== NESSUS VULNERABILITY SCANNER ==="' >> /entrypoint.sh && \
    echo 'echo "=========================================="' >> /entrypoint.sh && \
    echo 'echo "IP: 10.10.0.100"' >> /entrypoint.sh && \
    echo 'echo "Web UI: https://localhost:8834"' >> /entrypoint.sh && \
    echo 'echo "=========================================="' >> /entrypoint.sh && \
    echo 'echo ""' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'if [ -f /opt/nessus/sbin/nessusd ]; then' >> /entrypoint.sh && \
    echo '    echo "✅ Nessus instalado correctamente"' >> /entrypoint.sh && \
    echo '    VERSION=$(/opt/nessus/sbin/nessusd -v 2>/dev/null || echo "N/A")' >> /entrypoint.sh && \
    echo '    echo "📦 Versión: $VERSION"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    ' >> /entrypoint.sh && \
    echo '    if pgrep -f nessusd > /dev/null 2>&1; then' >> /entrypoint.sh && \
    echo '        echo "ℹ️  Nessus ya está ejecutándose"' >> /entrypoint.sh && \
    echo '    else' >> /entrypoint.sh && \
    echo '        echo "🚀 Iniciando Nessus..."' >> /entrypoint.sh && \
    echo '        /opt/nessus/sbin/nessusd' >> /entrypoint.sh && \
    echo '        sleep 10' >> /entrypoint.sh && \
    echo '        ' >> /entrypoint.sh && \
    echo '        if pgrep -f nessusd > /dev/null 2>&1; then' >> /entrypoint.sh && \
    echo '            echo "✅ Nessus iniciado correctamente"' >> /entrypoint.sh && \
    echo '        else' >> /entrypoint.sh && \
    echo '            echo "⚠️  Error al iniciar Nessus"' >> /entrypoint.sh && \
    echo '        fi' >> /entrypoint.sh && \
    echo '    fi' >> /entrypoint.sh && \
    echo '    ' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "=========================================="' >> /entrypoint.sh && \
    echo '    echo "📋 CONFIGURACIÓN INICIAL:"' >> /entrypoint.sh && \
    echo '    echo "=========================================="' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "1. Abre: https://localhost:8834"' >> /entrypoint.sh && \
    echo '    echo "   (Acepta el certificado SSL)"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "2. Selecciona: Nessus Essentials (GRATIS)"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "3. Crea usuario administrador:"' >> /entrypoint.sh && \
    echo '    echo "   Usuario: admin"' >> /entrypoint.sh && \
    echo '    echo "   Contraseña: admin123"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "4. Obtén código de activación GRATIS en:"' >> /entrypoint.sh && \
    echo '    echo "   https://www.tenable.com/products/nessus/nessus-essentials"' >> /entrypoint.sh && \
    echo '    echo "   (Recibirás por email: XXXX-XXXX-XXXX-XXXX-XXXX)"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "5. Ingresa el código y espera descarga de plugins"' >> /entrypoint.sh && \
    echo '    echo "   (Puede tomar 10-30 minutos la primera vez)"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "=========================================="' >> /entrypoint.sh && \
    echo '    echo "🎯 OBJETIVOS DEL LABORATORIO:"' >> /entrypoint.sh && \
    echo '    echo "=========================================="' >> /entrypoint.sh && \
    echo '    echo "10.10.0.20 - Metasploitable (SSH: msfadmin/msfadmin)"' >> /entrypoint.sh && \
    echo '    echo "10.10.0.21 - DVWA (Web: admin/password)"' >> /entrypoint.sh && \
    echo '    echo "10.10.0.30 - Windows Target"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    ' >> /entrypoint.sh && \
    echo '    echo "🔍 Verificando conectividad..."' >> /entrypoint.sh && \
    echo '    for ip in 10.10.0.20 10.10.0.21 10.10.0.30; do' >> /entrypoint.sh && \
    echo '        if ping -c 1 -W 1 $ip > /dev/null 2>&1; then' >> /entrypoint.sh && \
    echo '            echo "   ✅ $ip - Accesible"' >> /entrypoint.sh && \
    echo '        else' >> /entrypoint.sh && \
    echo '            echo "   ❌ $ip - No accesible"' >> /entrypoint.sh && \
    echo '        fi' >> /entrypoint.sh && \
    echo '    done' >> /entrypoint.sh && \
    echo 'else' >> /entrypoint.sh && \
    echo '    echo "❌ Nessus NO está instalado"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "La descarga automática no funcionó."' >> /entrypoint.sh && \
    echo '    echo "Instalación manual requerida:"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "1. Descarga desde:"' >> /entrypoint.sh && \
    echo '    echo "   https://www.tenable.com/downloads/nessus"' >> /entrypoint.sh && \
    echo '    echo "   Archivo: Nessus-10.x.x-ubuntu1404_amd64.deb"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo '    echo "2. Ejecuta:"' >> /entrypoint.sh && \
    echo '    echo "   .\\scripts\\install_nessus_real.ps1 manual Nessus-*.deb"' >> /entrypoint.sh && \
    echo '    echo ""' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'echo ""' >> /entrypoint.sh && \
    echo 'echo "=========================================="' >> /entrypoint.sh && \
    echo 'echo "✓ Contenedor listo"' >> /entrypoint.sh && \
    echo 'echo "=========================================="' >> /entrypoint.sh && \
    echo 'echo ""' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'tail -f /dev/null' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8834
VOLUME ["/opt/nessus/var", "/opt/nessus/lib/nessus/plugins"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD pgrep -f nessusd || exit 1

ENTRYPOINT ["/entrypoint.sh"]