# Laboratorio Nmap + Nessus

Laboratorio de escaneo de vulnerabilidades y análisis de seguridad. Guía completa para montar y ejecutar un laboratorio de Nmap, NSE y Nessus con Docker y Máquinas Virtuales.

## Tabla de Contenidos

- [Objetivos del Laboratorio](#objetivos-del-laboratorio)
- [Arquitectura del Laboratorio](#arquitectura-del-laboratorio)
  - [Opción Docker (Recomendada)](#opción-docker-recomendada)
  - [Opción Máquinas Virtuales](#opción-máquinas-virtuales)
- [Módulos del Laboratorio](#módulos-del-laboratorio)
- [Ejercicios Prácticos](#ejercicios-prácticos)
- [Scripts y Herramientas](#scripts-y-herramientas)
- [Solución de Problemas](#solución-de-problemas)

---

## Objetivos del Laboratorio

- **Entender diferencias** entre escaneo de red, detección de servicios, detección de versiones y análisis de vulnerabilidades
- **Dominar Nmap**: opciones, timing, técnicas avanzadas y scripting (NSE)
- **Dominar Nessus**: creación de políticas, escaneos credentialed vs non-credentialed, interpretación de plugins y reportes
- **Integrar resultados**: exportar, correlacionar Nmap y Nessus y priorizar remediaciones
- **Automatizar procesos**: scripts Python para procesamiento y análisis de datos

---

## Arquitectura del Laboratorio

### Red del Laboratorio
- **Subnet**: `10.10.0.0/24`
- **Gateway**: `10.10.0.1` (opcional)
- **Aislada**: Completamente separada de redes de producción

### Componentes del Laboratorio

| Componente | IP | Función | Acceso |
|------------|----|---------|---------| 
| **Kali Linux** | 10.10.0.10 | Herramientas de escaneo y ataque | SSH:2222 |
| **Metasploitable** | 10.10.0.20 | Sistema Linux vulnerable | SSH:2220, Web:8050, SMB:8082 |
| **DVWA** | 10.10.0.21 | Aplicación web vulnerable | HTTP:8180, MySQL:8330 |
| **Windows Target** | 10.10.0.30 | Simulador Windows | RDP:8149, SMB:8445 |
| **Nessus** | 10.10.0.100 | Escáner de vulnerabilidades | HTTPS:8834 ([Ver guía](docs/INSTALACION_NESSUS_DOCKER.md)) |
| **Elasticsearch** | 10.10.0.40 | Motor de búsqueda | API:9200 |
| **Kibana** | 10.10.0.41 | Visualización de datos | Web UI:5601 |

---

---

## Opción A: Docker (Recomendada)

### Por qué Docker
- **Setup rápido**: 5-10 minutos
- **Fácil mantenimiento**: Un comando para todo
- **Portabilidad**: Funciona en Windows, Mac, Linux
- **Menor consumo**: 4GB RAM, 10GB disco
- **Ideal para**: Estudiantes, demostraciones, laboratorios rápidos

### Prerrequisitos

**IMPORTANTE - Descarga esto ANTES de empezar:**
- **Nessus (.deb)**: https://www.tenable.com/downloads/nessus
  - Selecciona: **Debian 10 (64-bit)** o **Ubuntu (64-bit)**
  - Archivo: `Nessus-10.x.x-debian10_amd64.deb`
  - Guárdalo en tu carpeta de **Downloads**

**Software necesario:**
- Docker Desktop o Docker Engine
- Docker Compose v3.8+
- 4GB+ RAM, 10GB+ espacio en disco

### Instalación Paso a Paso

#### Paso 1: Clonar Repositorio
```bash
git clone https://github.com/la00429/Laboratorio_Nessus_Nmap_.git
cd Laboratorio_Nessus_Nmap_
```

#### Paso 2: Iniciar Docker Desktop
- Abrir Docker Desktop desde el menú de inicio
- Esperar a que se inicie completamente (ícono en bandeja del sistema)
- Verificar que esté ejecutándose: `docker version`

#### Paso 3: Construir Imágenes Docker
```bash
# Construir todas las imágenes
docker compose build

# NOTA: Usar "docker compose" (sin guión) en versiones recientes
```

#### Paso 4: Iniciar Laboratorio
```bash
# Iniciar todos los contenedores
docker compose up -d

# Verificar estado
docker compose ps
```

#### Paso 5: Verificar Conectividad
```bash
# Probar conectividad de red
docker compose exec kali nmap -sn 10.10.0.0/24

# Deberías ver todos los hosts del laboratorio
```

#### Paso 6: Instalar Nessus (Requerido para Módulo 4)

**IMPORTANTE**: Asegúrate de haber descargado el archivo `.deb` en el paso de Prerrequisitos.

**Instalación automática (1 comando):**
```powershell
# Ejecuta el script de instalación automática
.\scripts\setup_nessus.ps1
```

El script automáticamente:
- Busca el archivo `.deb` en Downloads
- Copia el archivo al contenedor
- Instala Nessus
- Inicia el servicio
- Abre el navegador

**Después de ejecutar el script:**
1. **Accede a**: https://localhost:8834
2. **Código gratis**: https://www.tenable.com/products/nessus/nessus-essentials
3. **Usuario**: admin / **Password**: admin123
4. **Espera** plugins (10-30 min)
5. **Targets**: `10.10.0.20,10.10.0.21,10.10.0.30`

**[Guía completa](docs/INSTALACION_NESSUS_DOCKER.md)** | **[Guía rápida](NESSUS_QUICKSTART.md)**

### Comandos de Gestión Docker

```bash
# Ver estado de contenedores
docker compose ps

# Ver logs en tiempo real
docker compose logs -f

# Reiniciar todo
docker compose restart

# Detener todo
docker compose down

# Iniciar todo
docker compose up -d
```

### Acceso a Servicios Docker

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **Kali SSH** | `ssh root@localhost -p 2222` | root/kali123 |
| **DVWA** | http://localhost:8180 | admin/password |
| **Nessus** | https://localhost:8834 | admin/admin123 ([Requiere instalación manual](docs/INSTALACION_NESSUS_DOCKER.md)) |
| **Kibana** | http://localhost:5601 | - |
| **Elasticsearch** | http://localhost:9200 | - |

---

## Opción B: Máquinas Virtuales (Tradicional)

### Cuándo usar VMs
- **Realismo total**: Comportamiento de sistemas reales
- **Flexibilidad máxima**: Control completo de configuración
- **Técnicas avanzadas**: Pivoting, post-explotación compleja
- **Experiencia realista**: Simulación de entornos corporativos
- **Ideal para**: Profesionales, certificaciones, estudios avanzados

### Prerrequisitos
- **Hipervisor**: VirtualBox, VMware Workstation, o Proxmox
- **Hardware**: 8GB+ RAM, 50GB+ disco
- **Funcionalidades**: Snapshot capabilities
- **Red**: Host-only o NAT interna configurada

### Configuración de VMs

#### Kali Linux VM
- **OS**: Kali Linux 2023.x
- **RAM**: 2GB mínimo
- **Disco**: 20GB
- **IP**: 10.10.0.10
- **Herramientas**: nmap, python3, metasploit

#### Metasploitable2 VM
- **OS**: Ubuntu 8.04 LTS (Metasploitable2)
- **RAM**: 1GB
- **Disco**: 10GB
- **IP**: 10.10.0.20
- **Credenciales**: msfadmin/msfadmin, root/password

#### DVWA VM
- **OS**: Ubuntu 20.04 LTS
- **RAM**: 1GB
- **Disco**: 10GB
- **IP**: 10.10.0.21
- **Servicios**: Apache, MySQL, DVWA

#### Windows Target VM
- **OS**: Windows Server 2019/2022
- **RAM**: 2GB
- **Disco**: 25GB
- **IP**: 10.10.0.30
- **Servicios**: IIS, SMB, RDP

#### Nessus VM
- **OS**: Ubuntu 20.04 LTS
- **RAM**: 2GB
- **Disco**: 20GB
- **IP**: 10.10.0.100
- **Puerto**: 8834

### Configuración de Red VM
```bash
# VirtualBox - Crear red host-only
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 10.10.0.1 --netmask 255.255.255.0

# Configurar VMs para usar red host-only
# Asignar IPs estáticas en cada VM
```

---

---

# Módulos del Laboratorio

> **Nota**: Los siguientes módulos funcionan tanto en Docker como en VMs. Los comandos son los mismos en ambas opciones.

---

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

# 7. Escaneo web específico
sudo nmap -p80,443 --script=http-* 10.10.0.21 -oA resultados/dvwa_web
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

# 4. Scripts SMB para Windows Target
sudo nmap -p445 --script=smb-* 10.10.0.30 -oN resultados/smb_nse.txt

# 5. Scripts de autenticación
sudo nmap --script=auth 10.10.0.20,10.10.0.21 -oN resultados/auth_nse.txt
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
./scripts/import_nmap_to_nessus_improved.sh -x resultados/scan.xml -n "Nmap Discovery" -t "10.10.0.20-30"
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

# Escaneo Windows Target
nmap -sS -sV --script=smb-* 10.10.0.30 -oA resultados/windows_target
```

#### 3. Procesamiento de Resultados
```bash
# Parsear XML a formatos útiles
python3 scripts/parse_nmap_xml.py resultados/metasploitable_full.xml --csv reports/metasploitable.csv --json reports/metasploitable.json

# Importar a Nessus para análisis adicional
./scripts/import_nmap_to_nessus_improved.sh -x resultados/metasploitable_full.xml -n "Metasploitable Analysis"
```

#### 4. Análisis con Nessus
1. Acceder a Nessus Web UI
2. Crear política de escaneo
3. Configurar targets basados en resultados de Nmap
4. Ejecutar escaneos credentialed y non-credentialed
5. Analizar plugins y CVSS
6. Exportar reportes

---

## Scripts y Herramientas

### Scripts de Automatización

#### `parse_nmap_xml.py`
- **Función**: Procesa archivos XML de Nmap
- **Salidas**: CSV, JSON, resumen ejecutivo
- **Uso**: `python3 scripts/parse_nmap_xml.py scan.xml --csv report.csv --json report.json`

#### `import_nmap_to_nessus_improved.sh`
- **Función**: Prepara importación de resultados Nmap a Nessus
- **Características**: Extrae hosts, crea targets, genera instrucciones
- **Uso**: `./scripts/import_nmap_to_nessus_improved.sh -x scan.xml -n "Scan Name"`

#### `verify_lab.sh`
- **Función**: Verificación completa del laboratorio
- **Características**: Estado de contenedores, conectividad, servicios
- **Uso**: `./scripts/verify_lab.sh`

#### `fix_nessus_access.sh`
- **Función**: Solución de problemas de Nessus
- **Características**: Diagnóstico automático, reinicio, reconstrucción
- **Uso**: `./scripts/fix_nessus_access.sh --auto-fix`

#### `quick_fix_all.sh`
- **Función**: Solución automática de todos los problemas
- **Características**: Limpieza completa, reconstrucción, reinicio
- **Uso**: `./scripts/quick_fix_all.sh`

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

## Solución de Problemas

### Problemas Comunes Docker

#### 1. "docker-compose command not found"
```bash
# Solución: Usar docker compose (sin guión)
docker compose build
docker compose up -d
```

#### 2. "Docker Desktop not running"
```bash
# Verificar estado
docker version
# Si falla, iniciar Docker Desktop manualmente
```

#### 3. "WSL2 integration required"
- Abrir Docker Desktop
- Ir a Settings > Resources > WSL Integration
- Habilitar integración con WSL2
- Reiniciar Docker Desktop

#### 4. Contenedores reiniciándose
```bash
# Ver logs del contenedor problemático
docker compose logs [nombre-contenedor]

# Reconstruir imagen específica
docker compose build --no-cache [nombre-contenedor]
```

#### 5. Nessus no accesible
```bash
# Diagnosticar problemas de Nessus
./scripts/fix_nessus_access.sh

# Solución automática
./scripts/fix_nessus_access.sh --auto-fix
```

### Problemas Comunes VMs
1. **Verificar conectividad**: `ping` entre todos los componentes
2. **Revisar logs**: Logs de VMs
3. **Verificar recursos**: RAM, CPU, espacio en disco
4. **Consultar documentación**: Guías específicas por plataforma

### Limpieza Completa
```bash
# Docker
docker compose down -v
docker system prune -f
docker compose build --no-cache
docker compose up -d

# VMs
# Hacer snapshots antes de cambios importantes
# Restaurar desde snapshot si es necesario
```

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

## Estado del Laboratorio

### Completamente Funcional

| Componente | Estado | Última Actualización |
|------------|--------|---------------------|
| **Docker Compose** | Funcionando | Enero 2025 |
| **Todos los Contenedores** | Estables | Enero 2025 |
| **Scripts de Utilidad** | Actualizados | Enero 2025 |
| **Documentación** | Actualizada | Enero 2025 |

### Listo para Usar

El laboratorio está completamente operativo y listo para ejercicios de seguridad. Todos los componentes están funcionando correctamente.

## Documentación Adicional

- **[Guía Completa](guia.md)** - Instrucciones detalladas para el laboratorio
- **[Inicio Rápido Docker](docs/QUICKSTART.md)** - Setup en 10 minutos
- **[Configuración Docker](docs/DOCKER_SETUP.md)** - Documentación detallada

## Soporte

Para problemas o dudas:
1. Consultar la [Guía Completa](guia.md)
2. Revisar la sección de solución de problemas
3. Verificar el estado del laboratorio con los scripts incluidos

---

**Laboratorio creado para Redes de Datos**  
**Versión Docker y VM - 2025**  
**Estado**: Completamente Funcional