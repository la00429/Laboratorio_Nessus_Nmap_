#!/bin/bash

# Script para solucionar problemas de Docker Compose
# Ejecutar: chmod +x fix-docker.sh && ./fix-docker.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[FIX]${NC} $1"
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

# Banner
echo -e "${BLUE}"
echo "=================================================="
echo "    Solucionador de Problemas Docker"
echo "    Laboratorio Nmap + Nessus"
echo "=================================================="
echo -e "${NC}"

log "Deteniendo contenedores existentes..."
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true

log "Limpiando imágenes problemáticas..."
docker image prune -f 2>/dev/null || true

log "Eliminando imágenes del laboratorio (si existen)..."
docker rmi lab-nmap-nessus-kali:latest 2>/dev/null || true
docker rmi lab-nmap-nessus-nessus:latest 2>/dev/null || true
docker rmi lab-nmap-nessus-metasploitable:latest 2>/dev/null || true
docker rmi lab-nmap-nessus-dvwa:latest 2>/dev/null || true
docker rmi lab-nmap-nessus-windows:latest 2>/dev/null || true

log "Verificando estructura de directorios..."
mkdir -p scripts nse

log "Construyendo imágenes con nombres explícitos..."
if docker compose build --no-cache; then
    COMPOSE_CMD="docker compose"
elif docker-compose build --no-cache; then
    COMPOSE_CMD="docker-compose"
else
    log_error "No se pudo construir las imágenes"
    exit 1
fi

log_success "Imágenes construidas correctamente"

log "Iniciando laboratorio..."
$COMPOSE_CMD up -d

if [ $? -eq 0 ]; then
    log_success "Laboratorio iniciado correctamente"
    
    echo ""
    echo "Verificando estado..."
    sleep 5
    $COMPOSE_CMD ps
    
    echo ""
    log_success "¡Problemas solucionados!"
    echo ""
    echo "Accesos disponibles:"
    echo "- Kali Linux: ssh root@localhost -p 2222 (password: kali123)"
    echo "- Nessus: http://localhost:8834 (admin/admin123)"
    echo "- DVWA: http://localhost:8180 (admin/password)"
    echo ""
    echo "Para verificar conectividad:"
    echo "./scripts/verify_lab.sh"
    
else
    log_error "Error al iniciar el laboratorio"
    exit 1
fi
