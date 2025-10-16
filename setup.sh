#!/bin/bash

# Script de configuración inicial para el Laboratorio Docker Nmap + Nessus
# Ejecutar: chmod +x setup.sh && ./setup.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[SETUP]${NC} $1"
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
echo "    Laboratorio Docker - Nmap + Nessus"
echo "    Script de Configuración Inicial"
echo "=================================================="
echo -e "${NC}"

# Verificar prerrequisitos
log "Verificando prerrequisitos..."

# Verificar Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    log_success "Docker encontrado: $DOCKER_VERSION"
else
    log_error "Docker no está instalado"
    echo "Instala Docker desde: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar Docker Compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
    log_success "Docker Compose encontrado: $COMPOSE_VERSION"
elif docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short)
    log_success "Docker Compose (plugin) encontrado: $COMPOSE_VERSION"
else
    log_error "Docker Compose no está instalado"
    echo "Instala Docker Compose desde: https://docs.docker.com/compose/install/"
    exit 1
fi

# Verificar Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    log_success "Python3 encontrado: $PYTHON_VERSION"
else
    log_warning "Python3 no encontrado (necesario para scripts auxiliares)"
fi

# Verificar recursos del sistema
log "Verificando recursos del sistema..."

# Verificar memoria (mínimo 4GB)
if command -v free &> /dev/null; then
    MEMORY_GB=$(free -g | awk 'NR==2{print $2}')
    if [ "$MEMORY_GB" -lt 4 ]; then
        log_warning "Memoria insuficiente: ${MEMORY_GB}GB (recomendado: 4GB+)"
    else
        log_success "Memoria disponible: ${MEMORY_GB}GB"
    fi
fi

# Verificar espacio en disco (mínimo 10GB)
if command -v df &> /dev/null; then
    DISK_SPACE_GB=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$DISK_SPACE_GB" -lt 10 ]; then
        log_warning "Espacio en disco insuficiente: ${DISK_SPACE_GB}GB (recomendado: 10GB+)"
    else
        log_success "Espacio en disco disponible: ${DISK_SPACE_GB}GB"
    fi
fi

# Configurar archivo de entorno
log "Configurando variables de entorno..."

if [ ! -f ".env" ]; then
    if [ -f "env.example" ]; then
        cp env.example .env
        log_success "Archivo .env creado desde env.example"
    else
        log_error "Archivo env.example no encontrado"
        exit 1
    fi
else
    log "Archivo .env ya existe"
fi

# Crear directorios necesarios
log "Creando estructura de directorios..."

mkdir -p resultados reports data/{nessus,kali} nse docs

# Crear archivos de ejemplo si no existen
if [ ! -f "scripts/my-banner.nse" ]; then
    cat > scripts/my-banner.nse << 'EOF'
description = [[
  Simple NSE script that connects to a TCP port, reads up to 512 bytes and prints banner.
]]
author = "Laboratorio Docker"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discovery", "safe"}

require "shortport"
require "stdnse"
require "nmap"

portrule = function(host, port)
  return port.protocol == "tcp" and port.state == "open"
end

action = function(host, port)
  local socket = nmap.new_socket()
  socket:set_timeout(3000)
  local status, err = socket:connect(host.ip, port.number)
  if not status then
    return "connect error: " .. tostring(err)
  end
  local data, err = socket:receive_lines(1)
  socket:close()
  if data then
    return "banner: " .. data
  else
    return "no banner or read error: " .. tostring(err)
  end
end
EOF
    log_success "Script NSE de ejemplo creado: scripts/my-banner.nse"
fi

# Configurar permisos
log "Configurando permisos..."

chmod +x scripts/*.py scripts/*.sh 2>/dev/null || true
chmod +x setup.sh

# Verificar conectividad de red
log "Verificando conectividad de red..."

# Verificar que los puertos no estén en uso
PORTS=(2222 8180 8834)
for port in "${PORTS[@]}"; do
    if command -v netstat &> /dev/null; then
        if netstat -tuln | grep -q ":$port "; then
            log_warning "Puerto $port está en uso"
        fi
    fi
done

# Construir imágenes Docker
log "Construyendo imágenes Docker..."

if docker-compose build; then
    log_success "Imágenes Docker construidas correctamente"
else
    log_error "Error al construir imágenes Docker"
    exit 1
fi

# Mostrar información final
echo ""
echo -e "${GREEN}=================================================="
echo "    ¡CONFIGURACIÓN COMPLETADA!"
echo "=================================================="
echo -e "${NC}"

log_success "Laboratorio Docker configurado correctamente"
echo ""
echo "Próximos pasos:"
echo "1. Iniciar el laboratorio:"
echo "   ${BLUE}docker-compose up -d${NC}"
echo ""
echo "2. Verificar estado:"
echo "   ${BLUE}python3 scripts/docker-lab-helper.py status${NC}"
echo ""
echo "3. Acceder a Kali Linux:"
echo "   ${BLUE}ssh root@localhost -p 2222${NC} (password: kali123)"
echo ""
echo "4. Acceder a Nessus:"
echo "   ${BLUE}https://localhost:8834${NC} (admin/admin123)"
echo ""
echo "5. Acceder a DVWA:"
echo "   ${BLUE}http://localhost:8180${NC} (admin/password)"
echo ""
echo "Repositorio del proyecto:"
echo "   ${BLUE}https://github.com/la00429/Laboratorio_Nessus_Nmap_.git${NC}"
echo ""
echo "Documentación completa:"
echo "   ${BLUE}docs/DOCKER_SETUP.md${NC}"
echo "   ${BLUE}docs/QUICKSTART.md${NC}"
echo ""
echo "Helper script interactivo:"
echo "   ${BLUE}python3 scripts/docker-lab-helper.py interactive${NC}"
echo ""

log_success "¡Listo para comenzar!"
