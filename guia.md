# Guía de laboratorio: Nmap + NSE + Nessus + integración

> Guía práctica e impersonal para montar y ejecutar un laboratorio de escaneo y análisis de vulnerabilidades. Instrucciones reproducibles, comandos listos para copiar y secciones de reporte.

---

# 1. Objetivos del laboratorio

* Entender diferencias entre escaneo de red, detección de servicios, detección de versiones y análisis de vulnerabilidades.
* Dominar Nmap: opciones, timing, técnicas avanzadas y scripting (NSE).
* Dominar Nessus: creación de políticas, escaneos credentialed vs non-credentialed, interpretación de plugins y reportes.
* Integrar resultados: exportar, correlacionar Nmap y Nessus y priorizar remediaciones.

---

# 2. Requisitos y arquitectura recomendada

## Opción A: Docker (Recomendada - Más Rápido)

**Ventajas:**
* Setup en 5-10 minutos
* Fácil mantenimiento
* Portabilidad total
* Menor consumo de recursos

**Requisitos:**
* Docker y Docker Compose instalados
* 4GB+ RAM, 10GB+ disco
* **Nessus `.deb`** descargado ANTES de empezar

**Arquitectura Docker:**
* Subnet: `10.10.0.0/24`
* Componentes automáticos:
  * Attacker: **Kali Linux** — 10.10.0.10
  * Vulnerable 1: **Metasploitable** — 10.10.0.20
  * Vulnerable 2: **DVWA** — 10.10.0.21
  * Target Windows: **Simulador Windows** — 10.10.0.30
  * Nessus: **Nessus Scanner** — 10.10.0.100
  * Elasticsearch — 10.10.0.40
  * Kibana — 10.10.0.41

**Inicio rápido:**
```bash
# 1. Descargar Nessus .deb PRIMERO
# 2. Clonar repositorio y entrar
git clone <repo>
cd Laboratorio_Nessus_Nmap_

# 3. Iniciar todo
docker-compose up -d

# 4. Instalar Nessus automáticamente
.\scripts\setup_nessus.ps1
```

**Ver README.MD para instrucciones completas de Docker**

---

## Opción B: Máquinas Virtuales (Tradicional)

**Ventajas:**
* Realismo total
* Flexibilidad máxima
* Técnicas avanzadas de red

**Requisitos:**
* Host: PC o servidor con VirtualBox / VMware / Proxmox
* 8GB+ RAM, 50GB+ disco
* Red: NAT interna o host-only (aislada)

**VMs sugeridas (direcciones ejemplo en subnet 10.10.0.0/24):**
  * Attacker: **Kali Linux** — 10.10.0.10
  * Vulnerable 1: **Metasploitable2** — 10.10.0.20
  * Vulnerable 2: **OWASP BWA** o **DVWA** — 10.10.0.21
* Target Windows: **Windows Server evaluation** — 10.10.0.30
* Nessus Server: **Nessus** VM — 10.10.0.100

**Red:**
* Subnet: `10.10.0.0/24`
* Gateway: host si se requiere
* Aislar del resto de la red de producción

**Consejos operativos:**
* Hacer snapshots antes de cambios importantes
* No conectar a redes de producción
* Usar imágenes educativas (Metasploitable, VulnHub, DVWA)

---

>  **Nota**: El resto de esta guía usa comandos genéricos que funcionan en ambas opciones (Docker o VMs)

---

# 3. Estructura del repositorio (sugerida)

```
lab-nmap-nessus/
├─ resultados/
├─ scripts/
│  ├─ parse_nmap_xml.py
│  └─ import_nmap_to_nessus.sh
├─ nse/
│  └─ my-banner.nse
├─ docs/
│  └─ README.md
└─ reports/
```

---

# 4. Módulo 1 — Fundamentos y reconocimiento (Nmap básico)

## Teoría breve (resumen)

* ARP / ICMP / ICMP ping: detección de hosts vivos.
* TCP SYN scan `-sS`: rápido, requiere privilegios (raw sockets).
* Connect scan `-sT`: sin privilegios, más ruidoso.
* UDP scan `-sU`: lento, necesario para servicios UDP.
* Service/version `-sV`: identificación de software y versiones.
* OS detection `-O`: fingerprinting de la pila TCP/IP.
* Timing templates `-T0..-T5`: trade-off velocidad vs detección.
* Output formats: `-oN`, `-oX`, `-oG`, `-oA`.
* NSE: scripts categorizados (auth, discovery, vuln, brute, safe, intrusive).

## Ejercicios prácticos (comandos listos)

> Crear carpeta de resultados: `mkdir -p resultados`

1. **Ping sweep (descubrir hosts vivos)**

   ```
   nmap -sn 10.10.0.0/24 -oN resultados/ping_sweep.txt
   ```

2. **Escaneo SYN rápido de un host (puertos 1-65535)**

   ```
   sudo nmap -sS -Pn -p 1-65535 10.10.0.20 -T4 -oA resultados/syn_scan_metasploitable
   ```

   *Notas:* `-Pn` desactiva ping; `-T4` velocidad; `-oA` guarda en tres formatos.

3. **Detección de versiones y servicios (puertos seleccionados)**

   ```
   sudo nmap -sS -sV -p 22,80,139,445,3306 10.10.0.20 -oN resultados/versiones.txt
   ```

4. **Escaneo UDP básico (puertos comunes)**

   ```
   sudo nmap -sU -p 53,67,123 10.10.0.20 -T3 -oN resultados/udp.txt
   ```

5. **Detección de OS**

   ```
   sudo nmap -O 10.10.0.30 -oN resultados/os_detect.txt
   ```

6. **Escaneo agresivo (combinado)**

   ```
   sudo nmap -A -T4 10.10.0.20 -oN resultados/agresivo.txt
   ```

   `_A = -O, -sV, --script + traceroute_`

## Entregable Módulo 1

* Carpeta `resultados/` con salidas (`.nmap`, `.xml`, `.gnmap`, `.txt`).
* Mini informe (plantilla al final) con hallazgos críticos.

---

# 5. Módulo 2 — NSE (Nmap Scripting Engine)

## Teoría breve

* Tipos de scripts: `auth`, `discovery`, `vuln`, `brute`, `safe`, `intrusive`.
* Ubicación: `/usr/share/nmap/scripts/` (Kali).
* Uso: `--script <name>` o `--script <category>` (ej. `--script vuln`).

## Ejemplos prácticos

1. **Ejecutar scripts de vulnerabilidad**

   ```
   sudo nmap -sS -sV --script=vuln 10.10.0.20 -oN resultados/nse_vuln.txt
   ```

2. **Scripts HTTP específicos**

   ```
   sudo nmap -p80 --script=http-enum,http-vuln-cve2017-5638 10.10.0.21 -oN resultados/http_nse.txt
   ```

## Ejemplo de script NSE educativo (my-banner.nse)

/usr/share/nmap/scripts/ o `~/.nmap/scripts/`

```lua
description = [[
  Simple NSE script that connects to a TCP port, reads up to 512 bytes and prints banner.
]]
author = "TuNombre"
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
```

**Ejecutar:**

```
sudo nmap -sV --script my-banner 10.10.0.20 -oN resultados/my_banner.txt
```

## Entregable Módulo 2

* Scripts NSE creados/probados y explicación de su categoría.
* Salidas de prueba en `resultados/`.

---

# 6. Módulo 3 — Procesamiento y automatización (Python)

## Objetivo

* Parsear salida XML de Nmap y generar resumen (CSV/JSON) de puertos abiertos, servicios y hosts.

## Script básico (parse_nmap_xml.py)

Guardar en `scripts/parse_nmap_xml.py`

```python
#!/usr/bin/env python3
import xml.etree.ElementTree as ET
import sys
import csv
import json

if len(sys.argv) < 2:
    print("Uso: parse_nmap_xml.py scan.xml [--csv out.csv] [--json out.json]")
    sys.exit(1)

input_xml = sys.argv[1]
out_csv = None
out_json = None
if '--csv' in sys.argv:
    out_csv = sys.argv[sys.argv.index('--csv')+1]
if '--json' in sys.argv:
    out_json = sys.argv[sys.argv.index('--json')+1]

tree = ET.parse(input_xml)
root = tree.getroot()

results = []
for host in root.findall('host'):
    addr_elem = host.find('address')
    addr = addr_elem.get('addr') if addr_elem is not None else 'unknown'
    ports = host.find('ports')
    if ports is None:
        continue
    for port in ports.findall('port'):
        portid = port.get('portid')
        proto = port.get('protocol')
        state = port.find('state').get('state') if port.find('state') is not None else ''
        svc = port.find('service')
        service = svc.get('name') if svc is not None and 'name' in svc.attrib else ''
        version = svc.get('version') if svc is not None and 'version' in svc.attrib else ''
        results.append({
            'host': addr,
            'protocol': proto,
            'port': portid,
            'state': state,
            'service': service,
            'version': version
        })

if out_csv:
    keys = ['host','protocol','port','state','service','version']
    with open(out_csv, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=keys)
        writer.writeheader()
        writer.writerows(results)
if out_json:
    with open(out_json, 'w') as f:
        json.dump(results, f, indent=2)

for r in results:
    print(f"{r['host']} {r['protocol']}/{r['port']} {r['state']} {r['service']} {r['version']}")
```

**Ejecutar ejemplo:**

```
python3 scripts/parse_nmap_xml.py resultados/syn_scan_metasploitable.xml --csv reports/scan_summary.csv --json reports/scan_summary.json
```

## Uso de python-nmap (opcional)

```python
import nmap
nm = nmap.PortScanner()
nm.scan('10.10.0.20', '1-1024', arguments='-sV')
# procesar nm como en ejemplo
```

Instalar: `pip install python-nmap`

## Entregable Módulo 3

* `parse_nmap_xml.py` probado y outputs CSV/JSON.
* Script automatizado para importar XML a Nessus (o instrucciones para import manual).

---

# 7. Módulo 4 — Nessus: teoría y práctica

## Fundamentos

* Nessus usa plugins para detectar vulnerabilidades.
* **Credentialed scans**: con credenciales, descubren parches y configuraciones internas.
* **Non-credentialed scans**: visión externa, detección de servicios visibles.
* CVSS: usar para priorizar; considerar contexto y falsos positivos.

## Instalación de Nessus

###  Para Docker (Opción A - Recomendada)

 **ANTES DE EMPEZAR**: Descarga Nessus `.deb` desde https://www.tenable.com/downloads/nessus
- Selecciona: **Debian 10 (64-bit)** o **Ubuntu (64-bit)**

#### Instalación Automática (1 comando):
```powershell
# Ejecutar script de instalación
.\scripts\setup_nessus.ps1
```

#### Pasos manuales (alternativa):
```bash
# 1. Copiar archivo al contenedor
docker cp Nessus-10.x.x-debian10_amd64.deb nessus-lab:/tmp/Nessus.deb

# 2. Instalar
docker exec nessus-lab dpkg -i /tmp/Nessus.deb

# 3. Iniciar
docker exec nessus-lab /opt/nessus/sbin/nessusd
```

#### Configuración Inicial:
1. Acceder: `https://localhost:8834` (en el host) o `https://10.10.0.100:8834` (desde contenedores)
2. Código gratis: https://www.tenable.com/products/nessus/nessus-essentials
3. Usuario: `admin` / Password: `admin123`
4. Esperar descarga de plugins (10-30 minutos)

**Guía detallada Docker**: `docs/INSTALACION_NESSUS_DOCKER.md`

---

### Para Máquinas Virtuales (Opción B)

**Instalación en VM Linux:**
1. Descargar Nessus desde: https://www.tenable.com/downloads/nessus
2. Instalar según distribución:
   ```bash
   # Debian/Ubuntu
   sudo dpkg -i Nessus-*.deb
   
   # Red Hat/CentOS
   sudo rpm -ivh Nessus-*.rpm
   ```
3. Iniciar servicio:
   ```bash
   sudo systemctl start nessusd
   ```
4. Acceder: `https://IP-DE-TU-VM:8834`
5. Configurar con código de Tenable Essentials (gratis)

---

> **Nota**: El resto de ejercicios funcionan igual en Docker o VMs

## Ejercicios prácticos

### Ejercicio 1: Escaneo básico non-credentialed

**Objetivo:** Identificar servicios y vulnerabilidades visibles externamente.

**Pasos:**
1. Navegar a **Scans** → **New Scan**
2. Seleccionar template: **Basic Network Scan**
3. Configurar escaneo:
   - Name: `Lab-Basic-Scan`
   - Description: `Escaneo non-credentialed de objetivos del laboratorio`
   - Targets: `10.10.0.20,10.10.0.21,10.10.0.30`
4. Ejecutar: **Launch**
5. Esperar finalización (5-15 minutos dependiendo de la red)
6. Exportar resultados:
   - Formato: **PDF** (para documentación)
   - Formato: **HTML** (para análisis detallado)
   - Formato: **CSV** (para procesamiento)

**Resultados esperados:**
- Puertos abiertos en cada objetivo
- Versiones de servicios detectadas
- Vulnerabilidades de severidad Critical/High/Medium/Low
- Total de hallazgos por host

---

### Ejercicio 2: Escaneo credentialed (Linux)

**Objetivo:** Obtener información interna del sistema usando credenciales SSH.

**Pasos:**
1. Crear nueva política o editar escaneo anterior
2. Ir a **Credentials** → **SSH**
3. Configurar credenciales para 10.10.0.20 (Metasploitable):
   - Username: `msfadmin`
   - Password: `msfadmin`
   - Authentication method: `Password`
   - Elevate privileges with: `sudo` (opcional)
4. Configurar credenciales para 10.10.0.21 (DVWA):
   - Username: `root`
   - Password: `password`
   - Authentication method: `Password`
5. Guardar y ejecutar: **Launch**
6. Comparar resultados con escaneo non-credentialed

**Análisis comparativo:**
- Número de vulnerabilidades detectadas (non-cred vs cred)
- Plugins adicionales ejecutados con credenciales
- Información de sistema operativo obtenida
- Parches faltantes identificados
- Configuraciones inseguras encontradas

---

### Ejercicio 3: Análisis de plugins y priorización

**Objetivo:** Interpretar resultados y priorizar remediaciones.

**Procedimiento:**
1. Abrir reporte del escaneo credentialed
2. Filtrar por severidad: **Critical** y **High**
3. Para cada vulnerabilidad, documentar:

**Tabla de análisis:**
```
| Plugin ID | Nombre | Severidad | CVSS | Host | Puerto | Servicio | Explotable | Prioridad |
|-----------|--------|-----------|------|------|--------|----------|------------|-----------|
| 12345     | SSH Weak Encryption | High | 7.5 | 10.10.0.20 | 22 | SSH | Sí | Alta |
```

**Campos a analizar por plugin:**
- **Plugin Description**: Descripción técnica de la vulnerabilidad
- **Solution**: Pasos de remediación recomendados
- **See Also**: Referencias (CVE, advisories, patches)
- **CVSS Score**: Puntuación de severidad
- **CVSS Vector**: Vector de ataque (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
- **Exploitability**: Existe exploit público (Metasploit, ExploitDB)
- **Plugin Output**: Evidencia específica encontrada en el sistema

**Priorización:**
- **Prioridad 1 (Crítica)**: CVSS > 9.0, servicio expuesto, exploit disponible
- **Prioridad 2 (Alta)**: CVSS 7.0-8.9, servicio expuesto, información sensible
- **Prioridad 3 (Media)**: CVSS 4.0-6.9, servicios internos, falta de hardening
- **Prioridad 4 (Baja)**: CVSS < 4.0, informacional, falsos positivos potenciales

---

### Ejercicio 4: Configuración de políticas personalizadas

**Objetivo:** Crear política optimizada para el laboratorio.

**Pasos:**
1. Ir a **Policies** → **New Policy**
2. Seleccionar: **Advanced Scan**
3. Configurar en **Basic**:
   - Name: `Lab-Custom-Policy`
   - Description: `Política personalizada para entorno de laboratorio`
   
4. Configurar en **Discovery**:
   - Scan Type: `Full`
   - Port Scanning: `Default` o `All ports` (1-65535)
   - Port scan range: `1-65535`
   
5. Configurar en **Assessment**:
   - Web Applications: `Enabled` (para DVWA)
   - Brute Force: `Enabled` (cuidado en producción)
   - Denial of Service: `Disabled` (evitar caídas)
   
6. Configurar en **Report**:
   - Output: `Verbose`
   - Process info: `Enabled`
   - Show missing patches: `Enabled`
   
7. Configurar en **Performance**:
   - Max simultaneous hosts: `3` (ajustar según recursos)
   - Max checks per host: `5`
   - Network timeout: `5` seconds
   - Scan time limit: `Unlimited`
   
8. Guardar política y ejecutar escaneo

**Resultados esperados:**
- Mayor cobertura de vulnerabilidades
- Información detallada de configuración del sistema
- Recomendaciones específicas de hardening

---

### Ejercicio 5: Integración Nmap + Nessus

**Objetivo:** Correlacionar hallazgos de Nmap con Nessus.

**Fase 1: Escaneo con Nmap**
```bash
# Ejecutar escaneo completo con Nmap
nmap -sS -sV -p- 10.10.0.20,10.10.0.21,10.10.0.30 \
  -oX resultados/nmap_full_scan.xml \
  -oN resultados/nmap_full_scan.txt

# Ejecutar scripts de vulnerabilidad
nmap -sS -sV --script=vuln 10.10.0.20,10.10.0.21,10.10.0.30 \
  -oX resultados/nmap_vuln_scan.xml
```

**Fase 2: Importar a Nessus (opcional)**
- En Nessus: **Scans** → **Import Scan**
- Seleccionar archivo XML de Nmap
- Revisar targets detectados

**Fase 3: Correlación manual**

Crear tabla de correlación:
```
| Host | Puerto | Servicio | Versión Nmap | Vuln Nmap | Plugin Nessus | Severidad | Correlación |
|------|--------|----------|--------------|-----------|---------------|-----------|-------------|
| 10.10.0.20 | 22 | SSH | OpenSSH 6.6.1p1 | Weak encryption | 10881 | High | Coincide |
| 10.10.0.20 | 80 | HTTP | Apache 2.4.7 | Version EOL | 11422 | Medium | Coincide |
```

**Análisis:**
- Vulnerabilidades detectadas por ambas herramientas
- Vulnerabilidades únicas de Nessus (plugins específicos)
- Falsos positivos identificados
- Versiones confirmadas vs versiones reportadas

---

### Ejercicio 6: Escaneo de aplicaciones web (DVWA)

**Objetivo:** Identificar vulnerabilidades específicas de aplicaciones web.

**Pasos:**
1. Crear escaneo específico para 10.10.0.21 (DVWA)
2. Template: **Web Application Tests**
3. Configurar:
   - Target: `10.10.0.21`
   - Port: `80`
   - Enable: **Comprehensive tests**
   
4. En **Assessment** → **Web Applications**:
   - Test embedded web servers: `Enabled`
   - Maximum run time: `4 hours`
   - Follow HTTP redirects: `Enabled`
   - Test for SQL injection: `Enabled`
   - Test for XSS: `Enabled`
   - Test for CSRF: `Enabled`
   
5. Ejecutar y analizar:
   - Vulnerabilidades OWASP Top 10
   - Configuraciones inseguras de PHP/Apache
   - Credenciales por defecto
   - Archivos sensibles expuestos

**Vulnerabilidades esperadas en DVWA:**
- SQL Injection
- Cross-Site Scripting (XSS)
- CSRF
- File Inclusion
- Command Injection
- Insecure CAPTCHA
- Weak Session Handling

---

## Análisis y documentación de resultados

### Estructura del informe técnico

**1. Resumen ejecutivo**
- Total de hosts escaneados
- Total de vulnerabilidades por severidad
- Riesgo general del entorno
- Recomendaciones prioritarias

**2. Metodología**
- Herramientas utilizadas (Nessus version, plugins version)
- Tipo de escaneos realizados
- Credenciales utilizadas
- Limitaciones del escaneo

**3. Hallazgos por host**

Para cada host documentar:
```
Host: 10.10.0.20 (Metasploitable)
Sistema Operativo: Linux Ubuntu 8.04
Criticidad general: ALTA

Vulnerabilidades Críticas: 12
- Plugin 12345: Remote Code Execution en vsftpd
  - CVSS: 10.0
  - Solución: Actualizar a versión 3.0.3 o superior
  - Prioridad: INMEDIATA

Vulnerabilidades Altas: 28
- Plugin 23456: SSH Weak Encryption
  - CVSS: 7.5
  - Solución: Configurar algoritmos seguros en sshd_config
  - Prioridad: ALTA

[Continuar con todas las vulnerabilidades...]
```

**4. Matriz de riesgos**
```
| Severidad | Cantidad | % Total | Tendencia |
|-----------|----------|---------|-----------|
| Critical  | 15       | 5%      | Estable   |
| High      | 85       | 28%     | Aumento   |
| Medium    | 150      | 50%     | Estable   |
| Low       | 50       | 17%     | Reducción |
```

**5. Plan de remediación**

Priorizar por:
- Impacto en confidencialidad/integridad/disponibilidad
- Facilidad de explotación
- Exposición del servicio (interno vs externo)
- Criticidad del activo

**6. Anexos**
- Reportes completos PDF de Nessus
- Salidas XML de Nmap
- Screenshots de vulnerabilidades críticas
- Scripts utilizados para automatización

---

## Entregables del Módulo 4

**Archivos requeridos:**

1. **Políticas Nessus**
   - Política non-credentialed exportada (.nessus)
   - Política credentialed exportada (.nessus)
   - Política personalizada exportada (.nessus)

2. **Reportes de escaneos**
   - Escaneo básico: PDF + HTML + CSV
   - Escaneo credentialed: PDF + HTML + CSV
   - Escaneo de aplicación web: PDF + HTML

3. **Análisis técnico**
   - Documento con análisis de mínimo 10 plugins:
     * Plugin ID y nombre
     * Descripción técnica
     * Severidad y CVSS
     * Evidencia encontrada
     * Solución recomendada
     * Referencias (CVE, patches)
   
4. **Correlación Nmap-Nessus**
   - Tabla de correlación (formato CSV o Excel)
   - Análisis de coincidencias y diferencias
   - Falsos positivos identificados

5. **Plan de remediación**
   - Vulnerabilidades priorizadas
   - Timeframe de implementación
   - Recursos necesarios
   - Métricas de éxito

6. **Scripts y automatización**
   - Scripts utilizados para parsear resultados
   - Comandos de integración documentados
   - Procedimientos reproducibles

---

# 8. Correlación Nmap ↔ Nessus y priorización de remediaciones

## Procedimiento simple de correlación

1. Ejecutar Nmap discovery (`-oX`) para obtener puertos abiertos.
2. Importar Nmap XML a Nessus o usar CSV del parseador.
3. Filtrar findings de Nessus por host/puerto.
4. Regla básica de priorización:

   * `Critical` plugin sobre servicio expuesto → **Prioridad Alta**.
   * `High` plugin en servicio con puerto abierto y versión vulnerable → **Prioridad Media-Alta**.
   * Falsos positivos confirmados manualmente → **Bajar prioridad / marcar para re-scan**.

## Formato de salida recomendado

CSV con columnas:
`host,ip,port,service,version,nessus_plugin_id,nessus_severity,cvss,recommended_fix`

---

# 9. Seguridad, ética y buenas prácticas

* Nunca escanear activos fuera del laboratorio sin autorización explícita.
* Almacenar credenciales de pruebas fuera de repositorios públicos.
* Tomar snapshots antes de escaneos credentialed.
* Documentar cualquier prueba de explotación y revertir cambios.
* Evitar escaneos intrusivos en entornos productivos.

---

# 10. Checklist final (para marcar antes de cerrar)

* [ ] Red del laboratorio aislada y snapshots disponibles.
* [ ] Resultados Nmap en `resultados/` (XML + text).
* [ ] Scripts NSE probados y documentados.
* [ ] `parse_nmap_xml.py` generado y CSV/JSON exportado.
* [ ] Nessus instalado, políticas configuradas, escaneos credentialed y non-credentialed ejecutados.
* [ ] Reportes exportados (PDF/HTML) y análisis de plugins.
* [ ] Archivo de correlación Nmap↔Nessus generado y priorizaciones justificadas.
* [ ] Informe final y presentación preparada.

---

# 11. Plantilla breve de reporte (usar para cada escaneo)

```
Título: [Basic Network Scan - non-credentialed]
Fecha: 2025-10-13 10:00 UTC-5
Objetivo: 10.10.0.20-30
Comando/Política: Basic Network Scan / nmap -sS -sV -oX resultados/scan.xml
Tiempo ejecución: 00:12:34
Resumen ejecutivo:
  - Hosts vivos: 2
  - Hallazgos critical: 1
Hallazgos (tabla):
  host | puerto | servicio | plugin/CVE | severidad | recomendación
  10.10.0.20 | 80 | http | CVE-XXXX-YYYY | High | parchear paquete Z / actualizar
Recomendaciones inmediatas:
  1) Aislar servicio vulnerable
  2) Aplicar parche X
Archivos adjuntos: resultados/scan.xml, reports/scan_summary.csv, reports/scan.pdf
```

---

# 12. Tareas inmediatas sugeridas (copy-paste)

* Crear repo y estructura:

  ```
  mkdir -p lab-nmap-nessus/{resultados,scripts,nse,docs,reports}
  ```
* Persona Nmap: ejecutar ping sweep y subir `resultados/ping_sweep.txt`.
* Persona Nessus: desplegar Nessus VM y confirmar acceso `https://10.10.0.100:8834`.
* Persona Integración: colocar `scripts/parse_nmap_xml.py` y ejecutar contra un XML de ejemplo.

