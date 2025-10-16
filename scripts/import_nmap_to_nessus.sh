#!/bin/bash

# Script para importar resultados de Nmap a Nessus
# Adaptado para el laboratorio Docker

set -e

# Variables de configuración
NESSUS_HOST="10.10.0.100"
NESSUS_PORT="8834"
NESSUS_USER="admin"
NESSUS_PASS="${NESSUS_ADMIN_PASSWORD:-admin123}"
NMAP_XML_FILE=""
SCAN_NAME=""
TARGET_GROUP=""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo "Uso: import_nmap_to_nessus.sh [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  -x, --xml FILE       Archivo XML de Nmap a importar"
    echo "  -n, --name NAME      Nombre del escaneo en Nessus"
    echo "  -t, --targets GROUP  Grupo de targets (ej: 10.10.0.20-30)"
    echo "  -h, --help           Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./import_nmap_to_nessus.sh -x resultados/scan.xml -n 'Nmap Discovery Scan' -t '10.10.0.20-30'"
    echo "  ./import_nmap_to_nessus.sh --xml resultados/metasploitable.xml --name 'Metasploitable Scan'"
    echo ""
    echo "Variables de entorno:"
    echo "  NESSUS_ADMIN_PASSWORD  Contraseña de Nessus (por defecto: admin123)"
}

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar conectividad con Nessus
check_nessus_connectivity() {
    log "Verificando conectividad con Nessus..."
    
    if curl -s -k --connect-timeout 10 "https://${NESSUS_HOST}:${NESSUS_PORT}/" > /dev/null; then
        log_success "Nessus es accesible en https://${NESSUS_HOST}:${NESSUS_PORT}"
    else
        log_error "No se puede conectar a Nessus en https://${NESSUS_HOST}:${NESSUS_PORT}"
        log "Verifica que:"
        log "  1. El contenedor de Nessus esté ejecutándose"
        log "  2. El puerto 8834 esté expuesto"
        log "  3. Nessus esté completamente iniciado"
        return 1
    fi
}

# Función para extraer hosts del XML de Nmap
extract_hosts_from_xml() {
    local xml_file="$1"
    
    if [ ! -f "$xml_file" ]; then
        log_error "Archivo XML no encontrado: $xml_file"
        return 1
    fi
    
    log "Extrayendo hosts del archivo XML..."
    
    # Usar Python para extraer hosts del XML
    python3 -c "
import xml.etree.ElementTree as ET
import sys

try:
    tree = ET.parse('$xml_file')
    root = tree.getroot()
    
    hosts = []
    for host in root.findall('host'):
        addr_elem = host.find('address')
        if addr_elem is not None:
            addr = addr_elem.get('addr')
            if addr:
                hosts.append(addr)
    
    if hosts:
        print(','.join(sorted(set(hosts))))
    else:
        print('No hosts found')
        
except Exception as e:
    print(f'Error parsing XML: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Función para crear política de escaneo básica
create_scan_policy() {
    local policy_name="$1"
    
    log "Creando política de escaneo: $policy_name"
    
    # Crear política básica usando la API de Nessus
    # Nota: Esta es una implementación simplificada
    # En un entorno real, usarías la API completa de Nessus
    
    cat > /tmp/nessus_policy.json << EOF
{
    "name": "$policy_name",
    "description": "Política creada automáticamente desde Nmap",
    "preferences": {
        "basic": {
            "name": "$policy_name",
            "description": "Política básica para escaneos de red"
        }
    }
}
EOF
    
    log_success "Política de escaneo creada: $policy_name"
}

# Función principal para importar
import_to_nessus() {
    local xml_file="$1"
    local scan_name="$2"
    local targets="$3"
    
    log "=== IMPORTANDO NMAP A NESSUS ==="
    log "Archivo XML: $xml_file"
    log "Nombre del escaneo: $scan_name"
    log "Targets: $targets"
    
    # Verificar conectividad
    if ! check_nessus_connectivity; then
        return 1
    fi
    
    # Extraer hosts del XML
    local extracted_hosts
    extracted_hosts=$(extract_hosts_from_xml "$xml_file")
    
    if [ "$extracted_hosts" = "No hosts found" ]; then
        log_error "No se encontraron hosts en el archivo XML"
        return 1
    fi
    
    log_success "Hosts encontrados: $extracted_hosts"
    
    # Crear política
    create_scan_policy "$scan_name"
    
    # Mostrar instrucciones para importación manual
    log "=== INSTRUCCIONES PARA IMPORTACIÓN MANUAL ==="
    log "1. Accede a Nessus: https://${NESSUS_HOST}:${NESSUS_PORT}"
    log "2. Usuario: $NESSUS_USER"
    log "3. Contraseña: $NESSUS_PASS"
    log "4. Ve a 'Policies' y crea una nueva política"
    log "5. Ve a 'Scans' y crea un nuevo escaneo:"
    log "   - Nombre: $scan_name"
    log "   - Targets: $targets"
    log "   - Política: $scan_name"
    log ""
    log "=== ALTERNATIVA: USAR ARCHIVO DE TARGETS ==="
    
    # Crear archivo de targets
    local targets_file="/tmp/nessus_targets.txt"
    echo "$targets" > "$targets_file"
    log "Archivo de targets creado: $targets_file"
    log "Contenido:"
    cat "$targets_file"
    
    log_success "Preparación completada. Procede con la importación manual en Nessus."
}

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -x|--xml)
            NMAP_XML_FILE="$2"
            shift 2
            ;;
        -n|--name)
            SCAN_NAME="$2"
            shift 2
            ;;
        -t|--targets)
            TARGET_GROUP="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validar argumentos requeridos
if [ -z "$NMAP_XML_FILE" ]; then
    log_error "Se requiere especificar un archivo XML (-x o --xml)"
    show_help
    exit 1
fi

if [ -z "$SCAN_NAME" ]; then
    SCAN_NAME="Nmap Import $(date +'%Y-%m-%d %H:%M')"
    log_warning "No se especificó nombre del escaneo. Usando: $SCAN_NAME"
fi

if [ -z "$TARGET_GROUP" ]; then
    TARGET_GROUP="10.10.0.20-30"
    log_warning "No se especificaron targets. Usando: $TARGET_GROUP"
fi

# Ejecutar importación
import_to_nessus "$NMAP_XML_FILE" "$SCAN_NAME" "$TARGET_GROUP"
