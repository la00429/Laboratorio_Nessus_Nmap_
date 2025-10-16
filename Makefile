# Makefile para Laboratorio Docker - Nmap + Nessus
# Uso: make <comando>

.PHONY: help setup start stop restart status logs clean build test

# Variables
COMPOSE_FILE = docker-compose.yml
ENV_FILE = .env

# Colores
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Comando por defecto
help: ## Mostrar esta ayuda
	@echo "$(BLUE)Laboratorio Docker - Nmap + Nessus$(NC)"
	@echo "=================================="
	@echo "Repositorio: https://github.com/la00429/Laboratorio_Nessus_Nmap_.git"
	@echo ""
	@echo "Comandos disponibles:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Ejemplos:"
	@echo "  $(YELLOW)make setup$(NC)     # Configurar laboratorio por primera vez"
	@echo "  $(YELLOW)make start$(NC)     # Iniciar todos los contenedores"
	@echo "  $(YELLOW)make status$(NC)    # Ver estado del laboratorio"
	@echo "  $(YELLOW)make logs$(NC)      # Ver logs en tiempo real"

setup: ## Configurar laboratorio por primera vez
	@echo "$(BLUE)Configurando laboratorio...$(NC)"
	@chmod +x setup.sh
	@./setup.sh

build: ## Construir todas las imágenes Docker
	@echo "$(BLUE)Construyendo imágenes Docker...$(NC)"
	@docker-compose build

start: ## Iniciar laboratorio completo
	@echo "$(BLUE)Iniciando laboratorio...$(NC)"
	@docker-compose up -d
	@echo "$(GREEN)Laboratorio iniciado. Esperando servicios...$(NC)"
	@sleep 10
	@make status

stop: ## Detener laboratorio
	@echo "$(BLUE)Deteniendo laboratorio...$(NC)"
	@docker-compose down
	@echo "$(GREEN)Laboratorio detenido.$(NC)"

restart: ## Reiniciar laboratorio
	@echo "$(BLUE)Reiniciando laboratorio...$(NC)"
	@docker-compose restart
	@echo "$(GREEN)Laboratorio reiniciado.$(NC)"

status: ## Ver estado de contenedores
	@echo "$(BLUE)Estado del laboratorio:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)Verificando conectividad...$(NC)"
	@python3 scripts/docker-lab-helper.py status || echo "$(YELLOW)Helper script no disponible$(NC)"

logs: ## Ver logs en tiempo real
	@echo "$(BLUE)Logs del laboratorio (Ctrl+C para salir):$(NC)"
	@docker-compose logs -f

logs-kali: ## Ver logs de Kali Linux
	@docker-compose logs -f kali

logs-nessus: ## Ver logs de Nessus
	@docker-compose logs -f nessus

logs-dvwa: ## Ver logs de DVWA
	@docker-compose logs -f dvwa

shell-kali: ## Acceder a shell de Kali Linux
	@echo "$(BLUE)Accediendo a Kali Linux...$(NC)"
	@docker-compose exec kali bash

shell-nessus: ## Acceder a shell de Nessus
	@docker-compose exec nessus bash

shell-dvwa: ## Acceder a shell de DVWA
	@docker-compose exec dvwa bash

test-connectivity: ## Probar conectividad entre contenedores
	@echo "$(BLUE)Probando conectividad...$(NC)"
	@docker-compose exec kali ping -c 1 10.10.0.20 || echo "$(RED)Metasploitable no accesible$(NC)"
	@docker-compose exec kali ping -c 1 10.10.0.21 || echo "$(RED)DVWA no accesible$(NC)"
	@docker-compose exec kali ping -c 1 10.10.0.30 || echo "$(RED)Windows Target no accesible$(NC)"
	@docker-compose exec kali ping -c 1 10.10.0.100 || echo "$(RED)Nessus no accesible$(NC)"

nmap-scan: ## Ejecutar escaneo Nmap básico
	@echo "$(BLUE)Ejecutando escaneo Nmap...$(NC)"
	@docker-compose exec kali nmap -sn 10.10.0.0/24
	@echo ""
	@docker-compose exec kali nmap -sS -sV 10.10.0.20

nessus-status: ## Verificar estado de Nessus
	@echo "$(BLUE)Verificando estado de Nessus...$(NC)"
	@python3 scripts/docker-lab-helper.py nessus || echo "$(YELLOW)Helper script no disponible$(NC)"

info: ## Mostrar información del laboratorio
	@echo "$(BLUE)Información del laboratorio:$(NC)"
	@python3 scripts/docker-lab-helper.py info || echo "$(YELLOW)Helper script no disponible$(NC)"

fix: ## Solucionar problemas de Docker
	@echo "$(BLUE)Solucionando problemas de Docker...$(NC)"
	@chmod +x fix-docker.sh
	@./fix-docker.sh

clean: ## Limpiar contenedores y volúmenes
	@echo "$(RED)¿Estás seguro? Esto eliminará todos los datos. (y/N)$(NC)"
	@read -r confirm && [ "$$confirm" = "y" ] || exit 1
	@docker-compose down -v --rmi all
	@docker system prune -f
	@echo "$(GREEN)Limpieza completada.$(NC)"

clean-volumes: ## Limpiar solo volúmenes (mantener imágenes)
	@echo "$(YELLOW)Limpiando volúmenes...$(NC)"
	@docker-compose down -v
	@echo "$(GREEN)Volúmenes limpiados.$(NC)"

update: ## Actualizar imágenes Docker
	@echo "$(BLUE)Actualizando imágenes...$(NC)"
	@docker-compose pull
	@docker-compose build --no-cache
	@echo "$(GREEN)Imágenes actualizadas.$(NC)"

backup: ## Crear backup de volúmenes
	@echo "$(BLUE)Creando backup...$(NC)"
	@mkdir -p backups
	@docker run --rm -v lab-nmap-nessus_nessus_data:/data -v $$(pwd)/backups:/backup ubuntu tar czf /backup/nessus-backup-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "$(GREEN)Backup creado en backups/$(NC)"

restore: ## Restaurar backup (especificar ARCHIVO=backup.tar.gz)
	@if [ -z "$(ARCHIVO)" ]; then echo "$(RED)Especifica ARCHIVO=backup.tar.gz$(NC)"; exit 1; fi
	@echo "$(BLUE)Restaurando backup $(ARCHIVO)...$(NC)"
	@docker run --rm -v lab-nmap-nessus_nessus_data:/data -v $$(pwd)/backups:/backup ubuntu tar xzf /backup/$(ARCHIVO) -C /data
	@echo "$(GREEN)Backup restaurado.$(NC)"

monitor: ## Monitorear recursos del sistema
	@echo "$(BLUE)Monitoreando recursos...$(NC)"
	@docker stats

ports: ## Mostrar puertos expuestos
	@echo "$(BLUE)Puertos expuestos:$(NC)"
	@echo "Kali SSH:        localhost:2222"
	@echo "Nessus Web:      https://localhost:8834"
	@echo "DVWA Web:        http://localhost:8180"
	@echo "Metasploitable:  localhost:2220"
	@echo ""

network: ## Mostrar información de red
	@echo "$(BLUE)Información de red:$(NC)"
	@docker network ls
	@echo ""
	@docker network inspect lab-network || echo "$(YELLOW)Red lab-network no encontrada$(NC)"

interactive: ## Modo interactivo del helper
	@python3 scripts/docker-lab-helper.py interactive

# Comandos de desarrollo
dev-setup: ## Configurar entorno de desarrollo
	@echo "$(BLUE)Configurando entorno de desarrollo...$(NC)"
	@pip3 install -r requirements.txt 2>/dev/null || echo "$(YELLOW)requirements.txt no encontrado$(NC)"

dev-test: ## Ejecutar tests
	@echo "$(BLUE)Ejecutando tests...$(NC)"
	@python3 -m pytest tests/ 2>/dev/null || echo "$(YELLOW)Tests no configurados$(NC)"

# Comandos de documentación
docs: ## Generar documentación
	@echo "$(BLUE)Generando documentación...$(NC)"
	@echo "Documentación disponible en:"
	@echo "  - docs/DOCKER_SETUP.md"
	@echo "  - docs/QUICKSTART.md"
	@echo "  - README.MD"

# Comando por defecto si no se especifica objetivo
.DEFAULT_GOAL := help
