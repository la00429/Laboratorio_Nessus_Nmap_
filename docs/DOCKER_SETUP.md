# Laboratorio Docker - Nmap + Nessus

Esta guía te ayudará a configurar y ejecutar el laboratorio de escaneo de vulnerabilidades usando contenedores Docker.

## 🚀 Inicio Rápido

### Prerrequisitos

- Docker Desktop o Docker Engine
- Docker Compose v3.8+
- Al menos 4GB de RAM disponible
- 10GB de espacio en disco libre

### Instalación

1. **Clonar o descargar el proyecto**
   ```bash
   git clone <repository-url>
   cd lab-nmap-nessus-docker
   ```

2. **Configurar variables de entorno**
   ```bash
   cp env.example .env
   # Editar .env según tus necesidades
   ```

3. **Iniciar el laboratorio**
   ```bash
   docker-compose up -d
   ```

4. **Verificar el estado**
   ```bash
   python3 scripts/docker-lab-helper.py status
   ```

## 📋 Arquitectura del Laboratorio

### Red Docker
- **Subnet**: `10.10.0.0/24`
- **Gateway**: `10.10.0.1`
- **Aislada**: No conectada a redes externas

### Contenedores

| Contenedor | IP | Puerto | Descripción |
|------------|----|---------|-------------|
| **Kali Linux** | 10.10.0.10 | 2222 (SSH) | Herramientas de escaneo y ataque |
| **Metasploitable** | 10.10.0.20 | 2220 (SSH), 8020 (FTP) | Sistema Linux vulnerable |
| **DVWA** | 10.10.0.21 | 8180 (HTTP) | Aplicación web vulnerable |
| **Windows Target** | 10.10.0.30 | 8139 (SMB) | Simulador Windows para escaneos credentialed |
| **Nessus** | 10.10.0.100 | 8834 (HTTPS) | Escáner de vulnerabilidades |

## 🛠️ Uso del Laboratorio

### Acceso a Contenedores

#### Kali Linux (Herramientas de Escaneo)
```bash
# SSH
ssh root@localhost -p 2222
# Password: kali123

# SSH como usuario normal
ssh labuser@localhost -p 2222
# Password: lab123
```

#### Nessus (Escáner de Vulnerabilidades)
- **URL**: https://localhost:8834
- **Usuario**: admin
- **Contraseña**: admin123

#### DVWA (Aplicación Web Vulnerable)
- **URL**: http://localhost:8180
- **Usuario**: admin
- **Contraseña**: password

#### Metasploitable (Sistema Linux Vulnerable)
```bash
# SSH como root
ssh root@localhost -p 2220
# Password: password

# SSH como msfadmin
ssh msfadmin@localhost -p 2220
# Password: msfadmin
```

### Ejecutar Escaneos

#### Usando el Helper Script
```bash
# Modo interactivo
python3 scripts/docker-lab-helper.py interactive

# Comandos directos
python3 scripts/docker-lab-helper.py start
python3 scripts/docker-lab-helper.py status
python3 scripts/docker-lab-helper.py info
```

#### Escaneos Nmap Manuales
```bash
# Conectar a Kali
ssh root@localhost -p 2222

# Descubrir hosts
nmap -sn 10.10.0.0/24

# Escaneo básico
nmap -sS -sV 10.10.0.20

# Escaneo agresivo
nmap -A -T4 10.10.0.20

# Escaneo de vulnerabilidades
nmap -sS -sV --script=vuln 10.10.0.20
```

### Procesar Resultados

#### Parsear XML de Nmap
```bash
# Desde Kali o host
python3 scripts/parse_nmap_xml.py resultados/scan.xml --csv reports/summary.csv --json reports/summary.json
```

#### Importar a Nessus
```bash
# Preparar importación
./scripts/import_nmap_to_nessus.sh -x resultados/scan.xml -n "Nmap Discovery" -t "10.10.0.20-30"
```

## 📁 Estructura de Archivos

```
lab-nmap-nessus-docker/
├── docker-compose.yml          # Configuración principal
├── env.example                 # Variables de entorno
├── containers/                 # Dockerfiles y configuraciones
│   ├── kali/
│   ├── nessus/
│   ├── metasploitable/
│   ├── dvwa/
│   └── windows-target/
├── scripts/                    # Scripts de automatización
│   ├── parse_nmap_xml.py
│   ├── import_nmap_to_nessus.sh
│   └── docker-lab-helper.py
├── nse/                       # Scripts NSE personalizados
├── docs/                      # Documentación
├── reports/                   # Reportes generados
└── resultados/                # Resultados de escaneos
```

## 🔧 Comandos Útiles

### Gestión del Laboratorio
```bash
# Iniciar todo el laboratorio
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Detener laboratorio
docker-compose down

# Reiniciar un contenedor específico
docker-compose restart kali

# Ver estado de contenedores
docker-compose ps
```

### Acceso a Contenedores
```bash
# Ejecutar comando en Kali
docker exec -it kali-lab bash

# Ejecutar Nmap desde Kali
docker exec kali-lab nmap -sn 10.10.0.0/24

# Ver logs de Nessus
docker logs nessus-lab

# Copiar archivos desde/hacia contenedor
docker cp archivo.txt kali-lab:/workspace/
docker cp kali-lab:/workspace/resultados/ ./resultados/
```

### Limpieza y Mantenimiento
```bash
# Limpiar contenedores parados
docker-compose down --rmi all

# Limpiar volúmenes (¡CUIDADO! Borra datos)
docker-compose down -v

# Ver uso de espacio
docker system df

# Limpiar sistema Docker
docker system prune -a
```

## 🚨 Solución de Problemas

### Contenedor no inicia
```bash
# Ver logs del contenedor
docker logs <nombre-contenedor>

# Verificar recursos del sistema
docker stats

# Reiniciar Docker
sudo systemctl restart docker  # Linux
# Reiniciar Docker Desktop en Windows/Mac
```

### Problemas de Red
```bash
# Verificar redes Docker
docker network ls
docker network inspect lab-network

# Verificar conectividad
docker exec kali-lab ping -c 1 10.10.0.20
```

### Nessus no accesible
```bash
# Verificar que Nessus esté iniciado
docker logs nessus-lab

# Verificar puerto
netstat -tlnp | grep 8834

# Reiniciar Nessus
docker-compose restart nessus
```

## 📊 Ejercicios Prácticos

### Módulo 1: Escaneo Básico
1. Descubrir hosts vivos en la red
2. Escanear puertos en Metasploitable
3. Identificar servicios y versiones
4. Generar reportes en múltiples formatos

### Módulo 2: Scripts NSE
1. Ejecutar scripts de vulnerabilidad
2. Crear script NSE personalizado
3. Analizar banners de servicios
4. Documentar hallazgos

### Módulo 3: Integración
1. Parsear resultados XML con Python
2. Correlacionar datos de Nmap y Nessus
3. Priorizar vulnerabilidades
4. Generar reportes ejecutivos

### Módulo 4: Nessus
1. Configurar políticas de escaneo
2. Ejecutar escaneos credentialed y non-credentialed
3. Analizar plugins y CVSS
4. Exportar reportes

## 🔒 Consideraciones de Seguridad

- **Aislar el laboratorio**: Nunca conectar a redes de producción
- **Credenciales**: Cambiar contraseñas por defecto en producción
- **Snapshots**: Hacer backup de volúmenes importantes
- **Monitoreo**: Supervisar el uso de recursos
- **Actualizaciones**: Mantener imágenes Docker actualizadas

## 📞 Soporte

Para problemas o preguntas:
1. Revisar logs de contenedores
2. Verificar documentación en `/docs/`
3. Consultar issues conocidos
4. Crear nuevo issue con detalles del problema

---

**¡Importante!** Este laboratorio está diseñado únicamente para fines educativos. No usar en sistemas de producción sin autorización explícita.
