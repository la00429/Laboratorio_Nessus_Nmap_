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

## Hardware / VMs

* Host: PC o servidor con VirtualBox / VMware / Proxmox.
* Red: NAT interna o host-only (aislada).
* VMs sugeridas (direcciones ejemplo en subnet 10.10.0.0/24):

  * Attacker: **Kali Linux** — 10.10.0.10
  * Vulnerable 1: **Metasploitable2** — 10.10.0.20
  * Vulnerable 2: **OWASP BWA** o **DVWA** — 10.10.0.21
  * Target Windows: **Windows Server evaluation** — 10.10.0.30 (para escaneos credentialed)
  * Nessus Server: **Nessus** VM — 10.10.0.100 (puede convivir en la misma red)

## Red

* Subnet: `10.10.0.0/24`.
* Gateway: host si se requiere.
* Aislar el laboratorio del resto de la red de producción.

## Consejos operativos

* Hacer snapshots antes de cambios importantes.
* No conectar el laboratorio a redes de producción ni escanear sistemas no autorizados.
* Usar imágenes educativas (Metasploitable, VulnHub, DVWA).

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

## Instalación rápida (resumen)

1. Instalar Nessus en VM Linux (seguir guía oficial de Tenable).
2. Inicializar y registrar (Essentials/Professional según licencia).
3. Acceder: `https://10.10.0.100:8834`.

## Ejercicios prácticos

1. **Escaneo básico non-credentialed**

   * Template: *Basic Network Scan*
   * Objetivos: `10.10.0.20-30`
   * Ejecutar y exportar PDF/HTML.

2. **Escaneo credentialed (Linux)**

   * Configurar Credentials → SSH (username/key)
   * Ejecutar, comparar findings.

3. **Ajuste performance / exclusiones**

   * Max simultaneous hosts, Scan timeout para evitar DoS.

## Analizar reporte

* Revisar: `plugin description`, `solution`, `see also`, `cvss`, `plugin id`.
* Priorizar por `Critical` y `High`, evaluar exploitability y contexto.

## Integración con Nmap

* Importar XML de Nmap a Nessus para crear targets o para orientar escaneo credentialed.
* Flujo recomendado: Nmap discovery (rápido) → importar XML → escaneo credentialed en Nessus.

## Entregable Módulo 4

* Políticas Nessus configuradas y exportadas.
* Exportes PDF/HTML de escaneos credentialed y non-credentialed.
* Análisis de plugins (mínimo 10) con recomendaciones.

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

