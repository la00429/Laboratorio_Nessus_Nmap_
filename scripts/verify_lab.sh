#!/bin/bash

# Script de verificación completa del laboratorio
# Laboratorio Docker Nmap + Nessus

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Función para verificar Docker
check_docker() {
    log "Verificando Docker..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker no está instalado o no está en el PATH"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker no está ejecutándose"
        log "Inicia Docker Desktop y vuelve a intentar"
        return 1
    fi
    
    log_success "Docker está funcionando correctamente"
    return 0
}

# Función para verificar Docker Compose
check_docker_compose() {
    log "Verificando Docker Compose..."
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        log_error "Docker Compose no está disponible"
        return 1
    fi
    
    log_success "Docker Compose disponible: $COMPOSE_CMD"
    return 0
}

# Función para verificar archivos de configuración
check_config_files() {
    log "Verificando archivos de configuración..."
    
    local files=(
        "docker-compose.yml"
        "containers/kali/Dockerfile"
        "containers/nessus/Dockerfile"
        "containers/metasploitable/Dockerfile"
        "containers/dvwa/Dockerfile"
        "containers/windows-target/Dockerfile"
        "containers/elasticsearch/data"
        "containers/kibana/kibana.yml"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            log_success "✓ $file existe"
        else
            log_warning "⚠ $file no encontrado"
        fi
    done
}

# Función para verificar contenedores
check_containers() {
    log "Verificando estado de los contenedores..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        CONTAINERS=$(docker-compose ps --services)
    else
        CONTAINERS=$(docker compose ps --services)
    fi
    
    local running_count=0
    local total_count=0
    
    for container in $CONTAINERS; do
        total_count=$((total_count + 1))
        
        if [ "$COMPOSE_CMD" = "docker-compose" ]; then
            STATUS=$(docker-compose ps $container --format "table {{.State}}")
        else
            STATUS=$(docker compose ps $container --format "table {{.State}}")
        fi
        
        if echo "$STATUS" | grep -q "running"; then
            log_success "✓ $container está ejecutándose"
            running_count=$((running_count + 1))
        else
            log_warning "⚠ $container no está ejecutándose"
        fi
    done
    
    log "Resumen: $running_count/$total_count contenedores ejecutándose"
    
    if [ $running_count -eq $total_count ]; then
        log_success "✓ Todos los contenedores están ejecutándose"
        return 0
    else
        log_warning "⚠ Algunos contenedores no están ejecutándose"
        return 1
    fi
}

# Función para verificar conectividad de red
check_network_connectivity() {
    log "Verificando conectividad de red..."
    
    local targets=(
        "10.10.0.10"  # Kali
        "10.10.0.20"  # Metasploitable
        "10.10.0.21"  # DVWA
        "10.10.0.30"  # Windows Target
        "10.10.0.40"  # Elasticsearch
        "10.10.0.41"  # Kibana
        "10.10.0.100" # Nessus
    )
    
    local accessible_count=0
    local total_count=${#targets[@]}
    
    for target in "${targets[@]}"; do
        if [ "$COMPOSE_CMD" = "docker-compose" ]; then
            if docker-compose exec kali ping -c 1 -W 2 $target > /dev/null 2>&1; then
                log_success "✓ $target accesible desde Kali"
                accessible_count=$((accessible_count + 1))
            else
                log_warning "⚠ $target no accesible desde Kali"
            fi
        else
            if docker compose exec kali ping -c 1 -W 2 $target > /dev/null 2>&1; then
                log_success "✓ $target accesible desde Kali"
                accessible_count=$((accessible_count + 1))
            else
                log_warning "⚠ $target no accesible desde Kali"
            fi
        fi
    done
    
    log "Resumen: $accessible_count/$total_count targets accesibles"
    
    if [ $accessible_count -eq $total_count ]; then
        log_success "✓ Todos los targets son accesibles"
        return 0
    else
        log_warning "⚠ Algunos targets no son accesibles"
        return 1
    fi
}

# Función para verificar servicios específicos
check_services() {
    log "Verificando servicios específicos..."
    
    # Verificar SSH en Kali
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        if docker-compose exec kali netstat -tlnp | grep -q ":22"; then
            log_success "✓ SSH en Kali (puerto 22)"
        else
            log_warning "⚠ SSH en Kali no disponible"
        fi
    else
        if docker compose exec kali netstat -tlnp | grep -q ":22"; then
            log_success "✓ SSH en Kali (puerto 22)"
        else
            log_warning "⚠ SSH en Kali no disponible"
        fi
    fi
    
    # Verificar HTTP en DVWA
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        if docker-compose exec dvwa netstat -tlnp | grep -q ":80"; then
            log_success "✓ HTTP en DVWA (puerto 80)"
        else
            log_warning "⚠ HTTP en DVWA no disponible"
        fi
    else
        if docker compose exec dvwa netstat -tlnp | grep -q ":80"; then
            log_success "✓ HTTP en DVWA (puerto 80)"
        else
            log_warning "⚠ HTTP en DVWA no disponible"
        fi
    fi
    
    # Verificar Nessus
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        if docker-compose exec nessus netstat -tlnp | grep -q ":8834"; then
            log_success "✓ Nessus (puerto 8834)"
        else
            log_warning "⚠ Nessus no disponible"
        fi
    else
        if docker compose exec nessus netstat -tlnp | grep -q ":8834"; then
            log_success "✓ Nessus (puerto 8834)"
        else
            log_warning "⚠ Nessus no disponible"
        fi
    fi
}

# Función para verificar herramientas
check_tools() {
    log "Verificando herramientas en Kali..."
    
    local tools=("nmap" "python3" "curl" "wget")
    
    for tool in "${tools[@]}"; do
        if [ "$COMPOSE_CMD" = "docker-compose" ]; then
            if docker-compose exec kali which $tool > /dev/null 2>&1; then
                log_success "✓ $tool disponible en Kali"
            else
                log_warning "⚠ $tool no disponible en Kali"
            fi
        else
            if docker compose exec kali which $tool > /dev/null 2>&1; then
                log_success "✓ $tool disponible en Kali"
            else
                log_warning "⚠ $tool no disponible en Kali"
            fi
        fi
    done
}

# Función para verificar puertos expuestos
check_exposed_ports() {
    log "Verificando puertos expuestos..."
    
    local ports=(
        "2222:22"    # Kali SSH
        "8180:80"    # DVWA HTTP
        "8834:8834"  # Nessus
        "5601:5601"  # Kibana
        "9200:9200"  # Elasticsearch
    )
    
    for port in "${ports[@]}"; do
        local host_port=$(echo $port | cut -d: -f1)
        if netstat -tlnp 2>/dev/null | grep -q ":$host_port " || ss -tlnp 2>/dev/null | grep -q ":$host_port "; then
            log_success "✓ Puerto $host_port expuesto"
        else
            log_warning "⚠ Puerto $host_port no expuesto"
        fi
    done
}

# Función para mostrar resumen
show_summary() {
    log "=== RESUMEN DEL LABORATORIO ==="
    echo ""
    echo "Estado general:"
    echo "  - Docker: $(docker --version 2>/dev/null || echo 'No disponible')"
    echo "  - Docker Compose: $COMPOSE_CMD"
    echo ""
    echo "Acceso a servicios:"
    echo "  - Kali SSH: ssh root@localhost -p 2222 (password: kali123)"
    echo "  - DVWA: http://localhost:8180 (admin/password)"
    echo "  - Nessus: http://localhost:8834 (admin/admin123)"
    echo "  - Kibana: http://localhost:5601"
    echo "  - Elasticsearch: http://localhost:9200"
    echo ""
    echo "Comandos útiles:"
    echo "  - Ver estado: $COMPOSE_CMD ps"
    echo "  - Ver logs: $COMPOSE_CMD logs -f"
    echo "  - Reiniciar: $COMPOSE_CMD restart"
    echo "  - Detener: $COMPOSE_CMD down"
    echo "  - Iniciar: $COMPOSE_CMD up -d"
    echo ""
}

# Función para ejecutar prueba de conectividad
run_connectivity_test() {
    log "Ejecutando prueba de conectividad..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose exec kali nmap -sn 10.10.0.0/24
    else
        docker compose exec kali nmap -sn 10.10.0.0/24
    fi
}

# Función principal
main() {
    echo "=== VERIFICACIÓN COMPLETA DEL LABORATORIO ==="
    echo "Laboratorio Docker Nmap + Nessus"
    echo "============================================="
    echo ""
    
    # Verificar Docker
    if ! check_docker; then
        log_error "No se puede continuar sin Docker"
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! check_docker_compose; then
        log_error "No se puede continuar sin Docker Compose"
        exit 1
    fi
    
    # Verificar archivos de configuración
    check_config_files
    
    # Verificar contenedores
    check_containers
    
    # Verificar conectividad de red
    check_network_connectivity
    
    # Verificar servicios específicos
    check_services
    
    # Verificar herramientas
    check_tools
    
    # Verificar puertos expuestos
    check_exposed_ports
    
    # Mostrar resumen
    show_summary
    
    # Preguntar si ejecutar prueba de conectividad
    echo ""
    read -p "¿Ejecutar prueba de conectividad con Nmap? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_connectivity_test
    fi
    
    log_success "=== VERIFICACIÓN COMPLETADA ==="
}

# Ejecutar función principal
main "$@"
