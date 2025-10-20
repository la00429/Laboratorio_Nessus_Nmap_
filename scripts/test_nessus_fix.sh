#!/bin/bash

# Script para verificar que las correcciones de Nessus funcionan
# Ejecutar: ./scripts/test_nessus_fix.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[TEST]${NC} $1"
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

echo "=== VERIFICACIÓN DE CORRECCIONES DE NESSUS ==="
echo "Laboratorio Docker Nmap + Nessus"
echo "============================================="
echo ""

# Verificar que Docker esté ejecutándose
log "Verificando Docker..."
if ! docker info &> /dev/null; then
    log_error "Docker no está ejecutándose"
    exit 1
fi
log_success "Docker está funcionando"

# Verificar que el contenedor de Nessus esté ejecutándose
log "Verificando contenedor de Nessus..."
if ! docker ps | grep -q "nessus-lab"; then
    log_error "El contenedor de Nessus no está ejecutándose"
    log "Inicia el laboratorio con: docker compose up -d"
    exit 1
fi
log_success "Contenedor de Nessus está ejecutándose"

# Verificar que Apache esté ejecutándose dentro del contenedor
log "Verificando Apache en Nessus..."
if ! docker compose exec nessus service apache2 status &> /dev/null; then
    log_warning "Apache no está ejecutándose, intentando iniciarlo..."
    docker compose exec nessus service apache2 start
    sleep 2
fi

if docker compose exec nessus service apache2 status &> /dev/null; then
    log_success "Apache está ejecutándose en Nessus"
else
    log_error "Apache no se pudo iniciar en Nessus"
fi

# Verificar que el puerto 8834 esté abierto
log "Verificando puerto 8834..."
if docker compose exec nessus netstat -tlnp | grep -q ":8834"; then
    log_success "Puerto 8834 está abierto"
else
    log_warning "Puerto 8834 no está abierto"
fi

# Verificar conectividad HTTP
log "Verificando conectividad HTTP..."
if curl -s --connect-timeout 5 "http://localhost:8834/" > /dev/null 2>&1; then
    log_success "Nessus es accesible vía HTTP en localhost:8834"
else
    log_warning "Nessus no es accesible vía HTTP en localhost:8834"
fi

# Verificar conectividad interna
log "Verificando conectividad interna..."
if docker compose exec nessus curl -s --connect-timeout 5 "http://localhost:8834/" > /dev/null 2>&1; then
    log_success "Nessus responde internamente"
else
    log_warning "Nessus no responde internamente"
fi

# Verificar permisos de archivos
log "Verificando permisos de archivos..."
if docker compose exec nessus ls -la /opt/nessus/www/ | grep -q "www-data"; then
    log_success "Permisos de archivos configurados correctamente"
else
    log_warning "Permisos de archivos pueden necesitar ajuste"
fi

# Verificar configuración de Apache
log "Verificando configuración de Apache..."
if docker compose exec nessus apache2ctl -S 2>/dev/null | grep -q "nessus.conf"; then
    log_success "Configuración de Apache cargada correctamente"
else
    log_warning "Configuración de Apache puede necesitar verificación"
fi

echo ""
echo "=== RESUMEN DE VERIFICACIÓN ==="
echo ""

# Mostrar información de acceso
log "Información de acceso:"
echo "  - URL: http://localhost:8834"
echo "  - Usuario: admin"
echo "  - Contraseña: admin123"
echo ""

# Mostrar comandos útiles
log "Comandos útiles:"
echo "  - Ver logs: docker compose logs nessus"
echo "  - Reiniciar: docker compose restart nessus"
echo "  - Acceder: docker compose exec nessus bash"
echo ""

# Mostrar estado final
if curl -s --connect-timeout 5 "http://localhost:8834/" > /dev/null 2>&1; then
    log_success "=== NESSUS FUNCIONANDO CORRECTAMENTE ==="
    echo ""
    echo "Puedes acceder a Nessus en: http://localhost:8834"
    echo "Credenciales: admin / admin123"
else
    log_error "=== NESSUS NO ESTÁ FUNCIONANDO ==="
    echo ""
    echo "Ejecuta los siguientes comandos para solucionar:"
    echo "  docker compose restart nessus"
    echo "  ./scripts/fix_nessus_access.sh --auto-fix"
fi

echo ""
log "Verificación completada"
