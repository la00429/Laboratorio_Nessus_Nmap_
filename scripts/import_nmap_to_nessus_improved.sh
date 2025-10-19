#!/bin/bash

# Script mejorado para importar resultados de Nmap a Nessus
# Adaptado para el laboratorio Docker con simulador de Nessus

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
    echo "Uso: import_nmap_to_nessus_improved.sh [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  -x, --xml FILE       Archivo XML de Nmap a importar"
    echo "  -n, --name NAME      Nombre del escaneo en Nessus"
    echo "  -t, --targets GROUP  Grupo de targets (ej: 10.10.0.20-30)"
    echo "  -h, --help           Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./import_nmap_to_nessus_improved.sh -x resultados/scan.xml -n 'Nmap Discovery Scan' -t '10.10.0.20-30'"
    echo "  ./import_nmap_to_nessus_improved.sh --xml resultados/metasploitable.xml --name 'Metasploitable Scan'"
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
    
    # Verificar si el contenedor está ejecutándose
    if ! docker ps | grep -q "nessus-lab"; then
        log_error "El contenedor de Nessus no está ejecutándose"
        log "Inicia el laboratorio con: docker compose up -d"
        return 1
    fi
    
    # Verificar conectividad HTTP (el simulador usa HTTP, no HTTPS)
    if curl -s --connect-timeout 10 "http://${NESSUS_HOST}:${NESSUS_PORT}/" > /dev/null 2>&1; then
        log_success "Nessus es accesible en http://${NESSUS_HOST}:${NESSUS_PORT}"
    elif curl -s -k --connect-timeout 10 "https://${NESSUS_HOST}:${NESSUS_PORT}/" > /dev/null 2>&1; then
        log_success "Nessus es accesible en https://${NESSUS_HOST}:${NESSUS_PORT}"
    else
        log_error "No se puede conectar a Nessus en ${NESSUS_HOST}:${NESSUS_PORT}"
        log "Verifica que:"
        log "  1. El contenedor de Nessus esté ejecutándose: docker compose ps"
        log "  2. El puerto 8834 esté expuesto: docker compose port nessus 8834"
        log "  3. Nessus esté completamente iniciado: docker compose logs nessus"
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

# Función para extraer puertos abiertos del XML
extract_ports_from_xml() {
    local xml_file="$1"
    
    log "Extrayendo puertos abiertos del archivo XML..."
    
    python3 -c "
import xml.etree.ElementTree as ET
import sys

try:
    tree = ET.parse('$xml_file')
    root = tree.getroot()
    
    ports_info = []
    for host in root.findall('host'):
        addr_elem = host.find('address')
        if addr_elem is not None:
            addr = addr_elem.get('addr')
            if addr:
                ports = host.find('ports')
                if ports is not None:
                    for port in ports.findall('port'):
                        port_id = port.get('portid')
                        state = port.find('state')
                        if state is not None and state.get('state') == 'open':
                            service = port.find('service')
                            service_name = service.get('name') if service is not None else 'unknown'
                            ports_info.append(f'{addr}:{port_id}:{service_name}')
    
    if ports_info:
        for info in ports_info:
            print(info)
    else:
        print('No open ports found')
        
except Exception as e:
    print(f'Error parsing XML: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Función para crear archivo de configuración de Nessus
create_nessus_config() {
    local scan_name="$1"
    local targets="$2"
    local xml_file="$3"
    
    log "Creando configuración de Nessus..."
    
    # Crear directorio de configuración
    mkdir -p /tmp/nessus_config
    
    # Crear archivo de targets
    echo "$targets" > /tmp/nessus_config/targets.txt
    log_success "Archivo de targets creado: /tmp/nessus_config/targets.txt"
    
    # Crear archivo de política básica
    cat > /tmp/nessus_config/policy.txt << EOF
Política de Escaneo: $scan_name
Descripción: Política creada automáticamente desde Nmap
Targets: $targets
Archivo XML origen: $xml_file
Fecha: $(date)

Configuración recomendada:
- Escaneo básico de red
- Detección de servicios
- Análisis de vulnerabilidades básico
- Timeout: 30 segundos por host
- Máximo 10 hosts simultáneos
EOF
    
    log_success "Archivo de política creado: /tmp/nessus_config/policy.txt"
    
    # Crear resumen de puertos encontrados
    extract_ports_from_xml "$xml_file" > /tmp/nessus_config/ports_summary.txt
    log_success "Resumen de puertos creado: /tmp/nessus_config/ports_summary.txt"
}

# Función para mostrar instrucciones de importación
show_import_instructions() {
    local scan_name="$1"
    local targets="$2"
    
    log "=== INSTRUCCIONES PARA IMPORTACIÓN EN NESSUS ==="
    echo ""
    echo "1. ACCESO A NESSUS:"
    echo "   - URL: http://localhost:8834"
    echo "   - Usuario: $NESSUS_USER"
    echo "   - Contraseña: $NESSUS_PASS"
    echo ""
    echo "2. CREAR NUEVA POLÍTICA:"
    echo "   - Ve a 'Policies' → 'New Policy'"
    echo "   - Nombre: $scan_name"
    echo "   - Descripción: Política creada desde Nmap"
    echo "   - Selecciona 'Basic Network Scan'"
    echo ""
    echo "3. CREAR NUEVO ESCANEO:"
    echo "   - Ve a 'Scans' → 'New Scan'"
    echo "   - Nombre: $scan_name"
    echo "   - Targets: $targets"
    echo "   - Política: $scan_name (la que acabas de crear)"
    echo ""
    echo "4. CONFIGURACIÓN ADICIONAL:"
    echo "   - Schedule: Manual"
    echo "   - Notifications: None"
    echo "   - Advanced: Usar configuración por defecto"
    echo ""
    echo "5. ARCHIVOS DE REFERENCIA:"
    echo "   - Targets: /tmp/nessus_config/targets.txt"
    echo "   - Política: /tmp/nessus_config/policy.txt"
    echo "   - Puertos: /tmp/nessus_config/ports_summary.txt"
    echo ""
}

# Función para crear script de automatización
create_automation_script() {
    local scan_name="$1"
    local targets="$2"
    
    log "Creando script de automatización..."
    
    cat > /tmp/nessus_automation.sh << EOF
#!/bin/bash
# Script de automatización para Nessus
# Generado automáticamente por import_nmap_to_nessus_improved.sh

echo "=== AUTOMATIZACIÓN DE NESSUS ==="
echo "Scan: $scan_name"
echo "Targets: $targets"
echo ""

# Verificar conectividad
echo "Verificando conectividad con Nessus..."
if curl -s --connect-timeout 5 "http://10.10.0.100:8834/" > /dev/null; then
    echo "✓ Nessus accesible"
else
    echo "✗ Nessus no accesible"
    exit 1
fi

# Mostrar información de configuración
echo ""
echo "Configuración del escaneo:"
echo "- Nombre: $scan_name"
echo "- Targets: $targets"
echo "- Política: Basic Network Scan"
echo ""

# Mostrar archivos de referencia
echo "Archivos de referencia disponibles:"
ls -la /tmp/nessus_config/
echo ""

echo "Para continuar manualmente:"
echo "1. Abre http://localhost:8834 en tu navegador"
echo "2. Inicia sesión con admin/admin123"
echo "3. Crea la política y el escaneo según las instrucciones"
echo ""

EOF
    
    chmod +x /tmp/nessus_automation.sh
    log_success "Script de automatización creado: /tmp/nessus_automation.sh"
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
    
    # Crear configuración
    create_nessus_config "$scan_name" "$targets" "$xml_file"
    
    # Crear script de automatización
    create_automation_script "$scan_name" "$targets"
    
    # Mostrar instrucciones
    show_import_instructions "$scan_name" "$targets"
    
    log_success "Preparación completada. Archivos creados en /tmp/nessus_config/"
    log "Ejecuta /tmp/nessus_automation.sh para verificar la configuración"
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
