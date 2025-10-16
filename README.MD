# Laboratorio Nmap + Nessus - Guía Completa

> **Laboratorio de escaneo de vulnerabilidades y análisis de seguridad**  
> Guía práctica para montar y ejecutar un laboratorio completo de Nmap, NSE y Nessus con integración de herramientas.

## Tabla de Contenidos

- [Objetivos del Laboratorio](#objetivos-del-laboratorio)
- [Arquitectura del Laboratorio](#arquitectura-del-laboratorio)
- [Opciones de Instalación](#opciones-de-instalación)
  - [Opción Docker (Recomendada)](#opción-docker-recomendada)
  - [Opción Máquinas Virtuales](#opción-máquinas-virtuales)
- [Módulos del Laboratorio](#módulos-del-laboratorio)
- [Ejercicios Prácticos](#ejercicios-prácticos)
- [Herramientas y Scripts](#herramientas-y-scripts)
- [Reportes y Análisis](#reportes-y-análisis)
- [Consideraciones de Seguridad](#consideraciones-de-seguridad)

---

## Objetivos del Laboratorio

* **Entender diferencias** entre escaneo de red, detección de servicios, detección de versiones y análisis de vulnerabilidades
* **Dominar Nmap**: opciones, timing, técnicas avanzadas y scripting (NSE)
* **Dominar Nessus**: creación de políticas, escaneos credentialed vs non-credentialed, interpretación de plugins y reportes
* **Integrar resultados**: exportar, correlacionar Nmap y Nessus y priorizar remediaciones
* **Automatizar procesos**: scripts Python para procesamiento y análisis de datos

---

## Arquitectura del Laboratorio

### Red del Laboratorio
- **Subnet**: `10.10.0.0/24`
- **Gateway**: `10.10.0.1` (opcional)
- **Aislada**: Completamente separada de redes de producción

### Componentes del Laboratorio

| Componente | IP | Función | Acceso |
|------------|----|---------|---------| 
| **Kali Linux** | 10.10.0.10 | Herramientas de escaneo y ataque | SSH, herramientas CLI |
| **Metasploitable** | 10.10.0.20 | Sistema Linux vulnerable | SSH, servicios vulnerables |
| **DVWA** | 10.10.0.21 | Aplicación web vulnerable | HTTP, base de datos |
| **Windows Target** | 10.10.0.30 | Simulador Windows | SMB, RDP, servicios Windows |
| **Nessus** | 10.10.0.100 | Escáner de vulnerabilidades | Web UI HTTPS |

---

## Opciones de Instalación

### Opción Docker (Recomendada)

**Ventajas**: Portabilidad, facilidad de uso, aislamiento completo, rápido setup

#### Prerrequisitos
- Docker Desktop o Docker Engine
- Docker Compose v3.8+
- 4GB+ RAM, 10GB+ espacio en disco
- Python 3.7+ (para scripts auxiliares)

#### Instalación Express
```bash
# 1. Clonar repositorio
git clone https://github.com/la00429/Laboratorio_Nessus_Nmap_.git
cd Laboratorio_Nessus_Nmap_

# 2. Configurar automáticamente
chmod +x setup.sh
./setup.sh

# 3. Iniciar laboratorio
docker-compose up -d

# 4. Verificar estado
make status
# o
python3 scripts/docker-lab-helper.py status
```

#### Acceso Inmediato
- **Kali Linux**: `ssh root@localhost -p 2222` (password: kali123)
- **Nessus**: https://localhost:8834 (admin/admin123)
- **DVWA**: http://localhost:8180 (admin/password)
- **Metasploitable**: `ssh root@localhost -p 2220` (password: password)

#### Comandos Útiles Docker
```bash
# Gestión del laboratorio
make start          # Iniciar todo
make stop           # Detener todo
make restart        # Reiniciar
make status         # Ver estado
make logs           # Ver logs

# Acceso a contenedores
make shell-kali     # Acceder a Kali
make shell-nessus   # Acceder a Nessus
make shell-dvwa     # Acceder a DVWA

# Herramientas
make nmap-scan      # Escaneo básico
make test-connectivity # Probar conectividad
make interactive    # Modo interactivo
```

#### Documentación Docker
- **[Guía de Inicio Rápido](docs/QUICKSTART.md)** - Tener el lab funcionando en 10 minutos
- **[Configuración Completa](docs/DOCKER_SETUP.md)** - Documentación detallada

---

### Opción Máquinas Virtuales

**Ventajas**: Control total, simulación real de hardware, flexibilidad avanzada

#### Prerrequisitos
- VirtualBox, VMware o Proxmox
- 8GB+ RAM, 50GB+ espacio en disco
- Snapshot capabilities
- Red host-only o NAT interna

#### Configuración de VMs

##### Kali Linux VM
- **OS**: Kali Linux 2023.x
- **RAM**: 2GB mínimo
- **Disco**: 20GB
- **IP**: 10.10.0.10
- **Herramientas**: nmap, python3, metasploit

##### Metasploitable2 VM
- **OS**: Ubuntu 8.04 LTS (Metasploitable2)
- **RAM**: 1GB
- **Disco**: 10GB
- **IP**: 10.10.0.20
- **Credenciales**: msfadmin/msfadmin, root/password

##### DVWA VM
- **OS**: Ubuntu 20.04 LTS
- **RAM**: 1GB
- **Disco**: 10GB
- **IP**: 10.10.0.21
- **Servicios**: Apache, MySQL, DVWA

##### Windows Target VM
- **OS**: Windows Server 2019/2022
- **RAM**: 2GB
- **Disco**: 25GB
- **IP**: 10.10.0.30
- **Servicios**: IIS, SMB, RDP

##### Nessus VM
- **OS**: Ubuntu 20.04 LTS
- **RAM**: 2GB
- **Disco**: 20GB
- **IP**: 10.10.0.100
- **Puerto**: 8834

#### Configuración de Red VM
```bash
# VirtualBox - Crear red host-only
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 10.10.0.1 --netmask 255.255.255.0

# Configurar VMs para usar red host-only
# Asignar IPs estáticas en cada VM
```

#### Documentación VM
- **[Guía Original](guia.md)** - Instrucciones detalladas para VMs
- **[Esquema de Red](esquema.dot)** - Diagrama de la arquitectura

---

## Módulos del Laboratorio

### Módulo 1: Fundamentos y Reconocimiento (Nmap Básico)

#### Teoría
- **ARP/ICMP**: Detección de hosts vivos
- **TCP SYN scan (-sS)**: Rápido, requiere privilegios
- **Connect scan (-sT)**: Sin privilegios, más ruidoso
- **UDP scan (-sU)**: Lento, necesario para servicios UDP
- **Service/version (-sV)**: Identificación de software
- **OS detection (-O)**: Fingerprinting de la pila TCP/IP
- **Timing templates (-T0..-T5)**: Trade-off velocidad vs detección

#### Ejercicios Prácticos
```bash
# 1. Ping sweep (descubrir hosts vivos)
nmap -sn 10.10.0.0/24 -oN resultados/ping_sweep.txt

# 2. Escaneo SYN rápido
sudo nmap -sS -Pn -p 1-65535 10.10.0.20 -T4 -oA resultados/syn_scan_metasploitable

# 3. Detección de versiones
sudo nmap -sS -sV -p 22,80,139,445,3306 10.10.0.20 -oN resultados/versiones.txt

# 4. Escaneo UDP básico
sudo nmap -sU -p 53,67,123 10.10.0.20 -T3 -oN resultados/udp.txt

# 5. Detección de OS
sudo nmap -O 10.10.0.30 -oN resultados/os_detect.txt

# 6. Escaneo agresivo (combinado)
sudo nmap -A -T4 10.10.0.20 -oN resultados/agresivo.txt
```

### Módulo 2: NSE (Nmap Scripting Engine)

#### Teoría
- **Tipos de scripts**: auth, discovery, vuln, brute, safe, intrusive
- **Ubicación**: `/usr/share/nmap/scripts/` (Kali)
- **Uso**: `--script <name>` o `--script <category>`

#### Ejercicios Prácticos
```bash
# 1. Scripts de vulnerabilidad
sudo nmap -sS -sV --script=vuln 10.10.0.20 -oN resultados/nse_vuln.txt

# 2. Scripts HTTP específicos
sudo nmap -p80 --script=http-enum,http-vuln-cve2017-5638 10.10.0.21 -oN resultados/http_nse.txt

# 3. Script personalizado
sudo nmap -sV --script my-banner 10.10.0.20 -oN resultados/my_banner.txt
```

### Módulo 3: Procesamiento y Automatización (Python)

#### Objetivo
Parsear salida XML de Nmap y generar resumen (CSV/JSON) de puertos abiertos, servicios y hosts.

#### Scripts Disponibles
```bash
# Parsear resultados XML
python3 scripts/parse_nmap_xml.py resultados/scan.xml --csv reports/summary.csv --json reports/summary.json

# Helper interactivo (solo Docker)
python3 scripts/docker-lab-helper.py interactive

# Importar a Nessus
./scripts/import_nmap_to_nessus.sh -x resultados/scan.xml -n "Nmap Discovery" -t "10.10.0.20-30"
```

### Módulo 4: Nessus - Teoría y Práctica

#### Fundamentos
- **Plugins**: Sistema de detección de vulnerabilidades
- **Credentialed scans**: Con credenciales, descubren parches y configuraciones internas
- **Non-credentialed scans**: Visión externa, detección de servicios visibles
- **CVSS**: Usar para priorizar; considerar contexto y falsos positivos

#### Ejercicios Prácticos
1. **Escaneo básico non-credentialed**
   - Template: Basic Network Scan
   - Objetivos: `10.10.0.20-30`
   - Exportar PDF/HTML

2. **Escaneo credentialed (Linux)**
   - Configurar Credentials → SSH (username/key)
   - Ejecutar, comparar findings

3. **Ajuste performance/exclusiones**
   - Max simultaneous hosts, Scan timeout

---

## Ejercicios Prácticos

### Flujo de Trabajo Completo

#### 1. Descubrimiento de Red
```bash
# Descubrir hosts vivos
nmap -sn 10.10.0.0/24

# Escanear puertos en hosts descubiertos
nmap -sS -sV 10.10.0.20 10.10.0.21 10.10.0.30
```

#### 2. Análisis Detallado
```bash
# Escaneo completo con scripts
nmap -A -sV --script=vuln 10.10.0.20 -oA resultados/metasploitable_full

# Escaneo específico por servicios
nmap -p80,443 --script=http-* 10.10.0.21 -oA resultados/dvwa_web
```

#### 3. Procesamiento de Resultados
```bash
# Parsear XML a formatos útiles
python3 scripts/parse_nmap_xml.py resultados/metasploitable_full.xml --csv reports/metasploitable.csv --json reports/metasploitable.json

# Importar a Nessus para análisis adicional
./scripts/import_nmap_to_nessus.sh -x resultados/metasploitable_full.xml -n "Metasploitable Analysis"
```

#### 4. Análisis con Nessus
1. Acceder a Nessus Web UI
2. Crear política de escaneo
3. Configurar targets basados en resultados de Nmap
4. Ejecutar escaneos credentialed y non-credentialed
5. Analizar plugins y CVSS
6. Exportar reportes

---

## Herramientas y Scripts

### Scripts de Automatización

#### `parse_nmap_xml.py`
- **Función**: Procesa archivos XML de Nmap
- **Salidas**: CSV, JSON, resumen ejecutivo
- **Uso**: `python3 scripts/parse_nmap_xml.py scan.xml --csv report.csv --json report.json`

#### `import_nmap_to_nessus.sh`
- **Función**: Prepara importación de resultados Nmap a Nessus
- **Características**: Extrae hosts, crea targets, genera instrucciones
- **Uso**: `./scripts/import_nmap_to_nessus.sh -x scan.xml -n "Scan Name"`

#### `docker-lab-helper.py` (Solo Docker)
- **Función**: Gestión completa del laboratorio Docker
- **Características**: Inicio/parada, verificación, escaneos automatizados
- **Uso**: `python3 scripts/docker-lab-helper.py interactive`

### Scripts NSE Personalizados

#### `my-banner.nse`
- **Función**: Extrae banners de servicios TCP
- **Categoría**: discovery, safe
- **Uso**: `nmap -sV --script my-banner target`

### Herramientas del Laboratorio

#### Kali Linux
- **Nmap**: Escaneo de red y puertos
- **Python**: Scripts de automatización
- **Herramientas adicionales**: masscan, zmap, nikto, dirb

#### Nessus
- **Web UI**: Interfaz gráfica completa
- **API**: Automatización de escaneos
- **Plugins**: Base de datos de vulnerabilidades

---

## Reportes y Análisis

### Formato de Reportes

#### Resumen Ejecutivo
```
Título: [Basic Network Scan - non-credentialed]
Fecha: 2025-01-15 10:00 UTC-5
Objetivo: 10.10.0.20-30
Comando: nmap -sS -sV -oX resultados/scan.xml
Tiempo ejecución: 00:12:34

Resumen ejecutivo:
  - Hosts vivos: 3
  - Puertos abiertos: 45
  - Hallazgos critical: 2
  - Hallazgos high: 8
```

#### Tabla de Hallazgos
| Host | Puerto | Servicio | Plugin/CVE | Severidad | Recomendación |
|------|--------|----------|------------|-----------|---------------|
| 10.10.0.20 | 80 | http | CVE-2021-44228 | Critical | Actualizar Apache |
| 10.10.0.21 | 3306 | mysql | CVE-2020-1472 | High | Cambiar credenciales |

### Correlación Nmap ↔ Nessus

#### Procedimiento
1. Ejecutar Nmap discovery (`-oX`) para obtener puertos abiertos
2. Importar Nmap XML a Nessus o usar CSV del parser
3. Filtrar findings de Nessus por host/puerto
4. Priorizar por severidad y contexto

#### Reglas de Priorización
- `Critical` plugin sobre servicio expuesto → **Prioridad Alta**
- `High` plugin en servicio con puerto abierto y versión vulnerable → **Prioridad Media-Alta**
- Falsos positivos confirmados manualmente → **Bajar prioridad**

---

## Consideraciones de Seguridad

### Buenas Prácticas

#### Aislamiento
- **Laboratorio aislado**: Nunca conectar a redes de producción
- **Red host-only**: Aislar completamente del resto de la red
- **Snapshots**: Hacer backup antes de cambios importantes

#### Credenciales
- **Cambiar por defecto**: Modificar contraseñas de ejemplo
- **Almacenar seguras**: No commitear credenciales reales
- **Rotación**: Cambiar periódicamente en entornos de prueba

#### Monitoreo
- **Logs**: Mantener registro de todas las actividades
- **Alertas**: Configurar notificaciones de actividades sospechosas
- **Auditoría**: Revisar regularmente accesos y cambios

### Advertencias Importantes

**NUNCA** escanear activos fuera del laboratorio sin autorización explícita  
**NUNCA** usar credenciales reales en sistemas de producción  
**SIEMPRE** documentar pruebas de explotación y revertir cambios  
**SIEMPRE** evitar escaneos intrusivos en entornos productivos  

---

## Checklist Final

### Configuración Inicial
- [ ] Red del laboratorio aislada y configurada
- [ ] Todas las VMs/contenedores funcionando
- [ ] Conectividad entre todos los componentes
- [ ] Credenciales configuradas y documentadas
- [ ] Snapshots/backups realizados

### Ejercicios Completados
- [ ] Módulo 1: Nmap básico y reconocimiento
- [ ] Módulo 2: Scripts NSE y vulnerabilidades
- [ ] Módulo 3: Procesamiento y automatización
- [ ] Módulo 4: Nessus y análisis avanzado

### Entregables
- [ ] Resultados Nmap en múltiples formatos
- [ ] Scripts NSE personalizados documentados
- [ ] Scripts Python funcionando y probados
- [ ] Reportes Nessus exportados
- [ ] Análisis de correlación Nmap-Nessus
- [ ] Documentación de hallazgos y recomendaciones

### Limpieza
- [ ] Datos sensibles eliminados
- [ ] Credenciales de prueba cambiadas
- [ ] Logs y resultados archivados
- [ ] Sistema restaurado a estado inicial

---

## Soporte y Recursos

### Documentación Adicional
- **[Comparación Docker vs VMs](docs/COMPARISON.md)** - Guía para elegir la mejor opción
- **[Guía Docker](docs/DOCKER_SETUP.md)** - Configuración completa con contenedores
- **[Inicio Rápido](docs/QUICKSTART.md)** - Setup en 10 minutos
- **[Guía Original](guia.md)** - Instrucciones detalladas para VMs

### Comandos de Ayuda
```bash
# Docker
make help                    # Ver todos los comandos
python3 scripts/docker-lab-helper.py interactive  # Modo interactivo

# VMs
# Consultar guia.md para comandos específicos
```

### Resolución de Problemas
1. **Verificar conectividad**: `ping` entre todos los componentes
2. **Revisar logs**: Docker logs o logs de VMs
3. **Verificar recursos**: RAM, CPU, espacio en disco
4. **Consultar documentación**: Guías específicas por plataforma

---

## Licencia

Este laboratorio está diseñado únicamente para fines educativos. Ver archivo `LICENSE` para más detalles.

---

**¡Happy Hacking!** 🎉

> Laboratorio creado para el equipo H5 - Redes y Seguridad  
> Versión Docker y VM - 2025