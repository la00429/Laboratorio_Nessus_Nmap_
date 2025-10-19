#!/bin/bash

# Script de solución rápida para todos los problemas del laboratorio
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

# Función para detener todos los contenedores
stop_containers() {
    log "Deteniendo todos los contenedores..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose down
    else
        docker compose down
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Contenedores detenidos correctamente"
    else
        log_warning "Error al detener contenedores"
    fi
}

# Función para limpiar sistema Docker
clean_docker() {
    log "Limpiando sistema Docker..."
    
    # Limpiar contenedores parados
    docker container prune -f
    
    # Limpiar imágenes no utilizadas
    docker image prune -f
    
    # Limpiar volúmenes no utilizados
    docker volume prune -f
    
    # Limpiar red
    docker network prune -f
    
    log_success "Sistema Docker limpiado"
}

# Función para reconstruir imágenes
rebuild_images() {
    log "Reconstruyendo imágenes Docker..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose build --no-cache
    else
        docker compose build --no-cache
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Imágenes reconstruidas correctamente"
    else
        log_error "Error al reconstruir imágenes"
        return 1
    fi
}

# Función para iniciar contenedores
start_containers() {
    log "Iniciando contenedores..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Contenedores iniciados correctamente"
    else
        log_error "Error al iniciar contenedores"
        return 1
    fi
}

# Función para esperar a que los contenedores estén listos
wait_for_containers() {
    log "Esperando a que los contenedores estén listos..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt + 1))
        
        if [ "$COMPOSE_CMD" = "docker-compose" ]; then
            RUNNING_CONTAINERS=$(docker-compose ps --services --filter "status=running" | wc -l)
            TOTAL_CONTAINERS=$(docker-compose ps --services | wc -l)
        else
            RUNNING_CONTAINERS=$(docker compose ps --services --filter "status=running" | wc -l)
            TOTAL_CONTAINERS=$(docker compose ps --services | wc -l)
        fi
        
        if [ "$RUNNING_CONTAINERS" -eq "$TOTAL_CONTAINERS" ]; then
            log_success "Todos los contenedores están ejecutándose"
            return 0
        fi
        
        log "Esperando... ($RUNNING_CONTAINERS/$TOTAL_CONTAINERS contenedores ejecutándose)"
        sleep 10
    done
    
    log_warning "Timeout esperando a que los contenedores estén listos"
    return 1
}

# Función para verificar estado final
verify_final_state() {
    log "Verificando estado final..."
    
    # Verificar contenedores
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose ps
    else
        docker compose ps
    fi
    
    # Verificar conectividad básica
    log "Verificando conectividad básica..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        if docker-compose exec kali ping -c 1 10.10.0.20 > /dev/null 2>&1; then
            log_success "✓ Conectividad básica funcionando"
        else
            log_warning "⚠ Problemas de conectividad"
        fi
    else
        if docker compose exec kali ping -c 1 10.10.0.20 > /dev/null 2>&1; then
            log_success "✓ Conectividad básica funcionando"
        else
            log_warning "⚠ Problemas de conectividad"
        fi
    fi
}

# Función para mostrar información de acceso
show_access_info() {
    log "=== INFORMACIÓN DE ACCESO ==="
    echo ""
    echo "Servicios disponibles:"
    echo "  - Kali SSH: ssh root@localhost -p 2222 (password: kali123)"
    echo "  - DVWA: http://localhost:8180 (admin/password)"
    echo "  - Nessus: http://localhost:8834 (admin/admin123)"
    echo "  - Kibana: http://localhost:5601"
    echo "  - Elasticsearch: http://localhost:9200"
    echo ""
    echo "Comandos útiles:"
    echo "  - Ver estado: $COMPOSE_CMD ps"
    echo "  - Ver logs: $COMPOSE_CMD logs -f"
    echo "  - Acceder a Kali: $COMPOSE_CMD exec kali bash"
    echo "  - Escaneo básico: $COMPOSE_CMD exec kali nmap -sn 10.10.0.0/24"
    echo ""
}

# Función principal
main() {
    echo "=== SOLUCIÓN RÁPIDA DEL LABORATORIO ==="
    echo "Laboratorio Docker Nmap + Nessus"
    echo "=================================="
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
    
    # Preguntar si continuar
    echo ""
    read -p "¿Continuar con la solución automática? Esto detendrá y reconstruirá todos los contenedores. (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Operación cancelada"
        exit 0
    fi
    
    # Ejecutar solución
    log "Iniciando solución automática..."
    
    # 1. Detener contenedores
    stop_containers
    
    # 2. Limpiar sistema Docker
    clean_docker
    
    # 3. Reconstruir imágenes
    rebuild_images
    
    # 4. Iniciar contenedores
    start_containers
    
    # 5. Esperar a que estén listos
    wait_for_containers
    
    # 6. Verificar estado final
    verify_final_state
    
    # 7. Mostrar información de acceso
    show_access_info
    
    log_success "=== SOLUCIÓN COMPLETADA ==="
    echo ""
    echo "El laboratorio debería estar funcionando correctamente ahora."
    echo "Si aún tienes problemas, ejecuta: ./scripts/verify_lab.sh"
    echo ""
}

# Ejecutar función principal
main "$@"
