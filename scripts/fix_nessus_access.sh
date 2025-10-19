#!/bin/bash

# Script para diagnosticar y solucionar problemas de acceso a Nessus
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

# Función para verificar contenedores
check_containers() {
    log "Verificando estado de los contenedores..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        CONTAINERS=$(docker-compose ps --services)
    else
        CONTAINERS=$(docker compose ps --services)
    fi
    
    for container in $CONTAINERS; do
        if [ "$COMPOSE_CMD" = "docker-compose" ]; then
            STATUS=$(docker-compose ps $container --format "table {{.State}}")
        else
            STATUS=$(docker compose ps $container --format "table {{.State}}")
        fi
        
        if echo "$STATUS" | grep -q "running"; then
            log_success "✓ $container está ejecutándose"
        else
            log_warning "⚠ $container no está ejecutándose"
        fi
    done
}

# Función para verificar Nessus específicamente
check_nessus() {
    log "Verificando contenedor de Nessus..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        NESSUS_STATUS=$(docker-compose ps nessus --format "table {{.State}}")
    else
        NESSUS_STATUS=$(docker compose ps nessus --format "table {{.State}}")
    fi
    
    if echo "$NESSUS_STATUS" | grep -q "running"; then
        log_success "✓ Nessus está ejecutándose"
        
        # Verificar puerto
        log "Verificando puerto 8834..."
        if [ "$COMPOSE_CMD" = "docker-compose" ]; then
            PORT_CHECK=$(docker-compose port nessus 8834 2>/dev/null || echo "no port")
        else
            PORT_CHECK=$(docker compose port nessus 8834 2>/dev/null || echo "no port")
        fi
        
        if [ "$PORT_CHECK" != "no port" ]; then
            log_success "✓ Puerto 8834 está expuesto: $PORT_CHECK"
        else
            log_warning "⚠ Puerto 8834 no está expuesto"
        fi
        
        # Verificar conectividad interna
        log "Verificando conectividad interna..."
        if [ "$COMPOSE_CMD" = "docker-compose" ]; then
            docker-compose exec nessus curl -s --connect-timeout 5 "http://localhost:8834/" > /dev/null 2>&1
        else
            docker compose exec nessus curl -s --connect-timeout 5 "http://localhost:8834/" > /dev/null 2>&1
        fi
        
        if [ $? -eq 0 ]; then
            log_success "✓ Nessus responde internamente"
        else
            log_warning "⚠ Nessus no responde internamente"
        fi
        
    else
        log_error "✗ Nessus no está ejecutándose"
        return 1
    fi
}

# Función para verificar acceso desde el host
check_host_access() {
    log "Verificando acceso desde el host..."
    
    # Verificar HTTP
    if curl -s --connect-timeout 5 "http://localhost:8834/" > /dev/null 2>&1; then
        log_success "✓ Acceso HTTP a Nessus desde host: http://localhost:8834"
        return 0
    fi
    
    # Verificar HTTPS
    if curl -s -k --connect-timeout 5 "https://localhost:8834/" > /dev/null 2>&1; then
        log_success "✓ Acceso HTTPS a Nessus desde host: https://localhost:8834"
        return 0
    fi
    
    log_error "✗ No se puede acceder a Nessus desde el host"
    return 1
}

# Función para reiniciar Nessus
restart_nessus() {
    log "Reiniciando contenedor de Nessus..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose restart nessus
    else
        docker compose restart nessus
    fi
    
    if [ $? -eq 0 ]; then
        log_success "✓ Nessus reiniciado correctamente"
        sleep 10  # Esperar a que se inicie
    else
        log_error "✗ Error al reiniciar Nessus"
        return 1
    fi
}

# Función para reconstruir Nessus
rebuild_nessus() {
    log "Reconstruyendo contenedor de Nessus..."
    
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose stop nessus
        docker-compose build --no-cache nessus
        docker-compose up -d nessus
    else
        docker compose stop nessus
        docker compose build --no-cache nessus
        docker compose up -d nessus
    fi
    
    if [ $? -eq 0 ]; then
        log_success "✓ Nessus reconstruido correctamente"
        sleep 15  # Esperar a que se inicie
    else
        log_error "✗ Error al reconstruir Nessus"
        return 1
    fi
}

# Función para mostrar información de acceso
show_access_info() {
    log "=== INFORMACIÓN DE ACCESO A NESSUS ==="
    echo ""
    echo "URLs de acceso:"
    echo "  - HTTP:  http://localhost:8834"
    echo "  - HTTPS: https://localhost:8834"
    echo ""
    echo "Credenciales:"
    echo "  - Usuario: admin"
    echo "  - Contraseña: admin123"
    echo ""
    echo "Verificación de puertos:"
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose port nessus 8834 2>/dev/null || echo "  - Puerto no expuesto"
    else
        docker compose port nessus 8834 2>/dev/null || echo "  - Puerto no expuesto"
    fi
    echo ""
    echo "Logs de Nessus:"
    if [ "$COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose logs --tail=10 nessus
    else
        docker compose logs --tail=10 nessus
    fi
    echo ""
}

# Función para solucionar problemas automáticamente
auto_fix() {
    log "=== SOLUCIONANDO PROBLEMAS AUTOMÁTICAMENTE ==="
    
    # 1. Verificar Docker
    if ! check_docker; then
        log_error "No se puede continuar sin Docker"
        exit 1
    fi
    
    # 2. Verificar Docker Compose
    if ! check_docker_compose; then
        log_error "No se puede continuar sin Docker Compose"
        exit 1
    fi
    
    # 3. Verificar contenedores
    check_containers
    
    # 4. Verificar Nessus específicamente
    if ! check_nessus; then
        log "Intentando reiniciar Nessus..."
        if restart_nessus; then
            if check_nessus; then
                log_success "✓ Nessus solucionado con reinicio"
            else
                log "Intentando reconstruir Nessus..."
                if rebuild_nessus; then
                    if check_nessus; then
                        log_success "✓ Nessus solucionado con reconstrucción"
                    else
                        log_error "✗ No se pudo solucionar Nessus"
                        return 1
                    fi
                else
                    log_error "✗ Error al reconstruir Nessus"
                    return 1
                fi
            fi
        else
            log_error "✗ Error al reiniciar Nessus"
            return 1
        fi
    fi
    
    # 5. Verificar acceso desde host
    if ! check_host_access; then
        log_warning "Nessus está ejecutándose pero no es accesible desde el host"
        log "Esto puede ser normal si el contenedor está iniciando"
        log "Espera unos minutos y vuelve a verificar"
    fi
    
    # 6. Mostrar información de acceso
    show_access_info
    
    log_success "=== DIAGNÓSTICO COMPLETADO ==="
}

# Función principal
main() {
    echo "=== DIAGNÓSTICO Y SOLUCIÓN DE NESSUS ==="
    echo "Laboratorio Docker Nmap + Nessus"
    echo "========================================"
    echo ""
    
    # Verificar argumentos
    if [ "$1" = "--auto-fix" ]; then
        auto_fix
    else
        # Diagnóstico manual
        check_docker
        check_docker_compose
        check_containers
        check_nessus
        check_host_access
        show_access_info
        
        echo ""
        echo "Para solucionar problemas automáticamente, ejecuta:"
        echo "  $0 --auto-fix"
    fi
}

# Ejecutar función principal
main "$@"
