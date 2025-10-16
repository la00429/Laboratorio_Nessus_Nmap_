#!/bin/bash

# Script de inicialización para Nessus
echo "Inicializando Nessus..."

# Crear directorios necesarios
mkdir -p /opt/nessus/{var,plugins,logs,imports,etc}

# Configurar permisos
chown -R nessus:nessus /opt/nessus

# Configurar Nessus si es la primera vez
if [ ! -f /opt/nessus/etc/nessus.conf ]; then
    echo "Configurando Nessus por primera vez..."
    
    # Crear configuración básica
    cat > /opt/nessus/etc/nessus.conf << EOF
# Configuración básica de Nessus
nessusd {
    # Puerto web
    port = 8834
    
    # Directorio de plugins
    plugins_dir = /opt/nessus/plugins
    
    # Directorio de logs
    log_dir = /opt/nessus/logs
    
    # Directorio de datos
    data_dir = /opt/nessus/var
    
    # Configuración de red
    listen_address = 0.0.0.0
    listen_port = 8834
}
EOF
fi

# Actualizar plugins si es posible
echo "Actualizando plugins de Nessus..."
/opt/nessus/sbin/nessuscli update --all || echo "No se pudieron actualizar los plugins"

echo "Inicialización de Nessus completada."
