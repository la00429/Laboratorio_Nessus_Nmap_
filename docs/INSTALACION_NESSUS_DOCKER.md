# 🐳 Instalación de Nessus en Docker - Guía Completa

## ⚠️ ANTES DE EMPEZAR

### **1. Descarga Nessus PRIMERO**
🔗 https://www.tenable.com/downloads/nessus

**Selecciona:**
- Producto: **Nessus**  
- Plataforma: **Debian 10 (64-bit)** o **Ubuntu (64-bit)**
- Archivo: `Nessus-10.x.x-debian10_amd64.deb`
- **Guárdalo en**: `C:\Users\TU_USUARIO\Downloads\`

> ⚠️ Descarga la versión **.deb** (Linux), NO `.msi` (Windows) ni `.rpm` (Red Hat)

---

## 📋 Requisitos
- Docker y Docker Compose instalados y corriendo
- Archivo Nessus `.deb` descargado
- ~500MB de espacio en disco

---

## 🚀 Instalación (Método Automático - RECOMENDADO)

### **Opción A: Script Automático (1 comando)**

```powershell
# Ejecutar desde la carpeta del proyecto
.\scripts\setup_nessus.ps1
```

**El script automáticamente:**
- ✅ Busca el archivo `.deb` en Downloads
- ✅ Verifica que el contenedor esté corriendo
- ✅ Copia el archivo al contenedor
- ✅ Instala Nessus
- ✅ Inicia el servicio
- ✅ Te muestra la URL para acceder

---

## 🛠️ Instalación Manual (Si prefieres hacerlo paso a paso)

---

### **Paso 2: Iniciar el Laboratorio Docker**

```powershell
# Navegar a la carpeta del proyecto
cd Laboratorio_Nessus_Nmap_

# Iniciar todos los contenedores
docker-compose up -d

# Verificar que estén corriendo
docker-compose ps
```

Deberías ver todos los contenedores corriendo, incluyendo `nessus-lab`.

---

### **Paso 3: Copiar Nessus al Contenedor**

```powershell
# Copiar el archivo .deb al contenedor Docker
docker cp C:\Users\TU_USUARIO\Downloads\Nessus-10.10.0-debian10_amd64.deb nessus-lab:/tmp/Nessus.deb
```

> 📝 **Nota:** Reemplaza `TU_USUARIO` con tu nombre de usuario de Windows

**Alternativa si el comando anterior no funciona:**
```powershell
# Usar ruta completa
docker cp "Nessus-10.10.0-debian10_amd64.deb" nessus-lab:/tmp/Nessus.deb
```

---

### **Paso 4: Instalar Nessus en el Contenedor**

```powershell
# Instalar Nessus
docker exec nessus-lab dpkg -i /tmp/Nessus.deb

# Si hay errores de dependencias, ejecutar:
docker exec nessus-lab apt-get install -f -y
```

Deberías ver mensajes de instalación exitosa.

---

### **Paso 5: Iniciar el Servicio de Nessus**

```powershell
# Iniciar Nessus
docker exec nessus-lab /opt/nessus/sbin/nessusd
```

Verás algo como:
```
nessusd (Nessus) 10.10.0 [build 20152] for Linux
Processing the Nessus plugins...
[==================================================] 100%
All plugins loaded
```

---

### **Paso 6: Verificar que Nessus esté Corriendo**

```powershell
# Verificar el proceso
docker exec nessus-lab ps aux | findstr nessusd

# Ver logs del contenedor
docker logs nessus-lab
```

---

### **Paso 7: Acceder a la Interfaz Web de Nessus**

1. **Abre tu navegador** (Chrome, Edge, Firefox)
2. **Ve a:** `https://localhost:8834`
3. **Acepta el certificado SSL:**
   - Clic en **"Avanzado"** → **"Continuar a localhost"**

---

### **Paso 8: Configuración Inicial de Nessus**

#### **A. Obtener Código de Activación (GRATIS)**

1. Ve a: https://www.tenable.com/products/nessus/nessus-essentials
2. **Regístrate** con tu email institucional o personal
3. **Recibirás un email** con un código de activación como:
   ```
   XXXX-XXXX-XXXX-XXXX-XXXX
   ```

#### **B. Activar Nessus**

1. En la pantalla de bienvenida, selecciona:
   - **"Nessus Professional"** (luego ingresarás el código Essentials)
   - O busca la opción **"Register Nessus"**
2. **Ingresa el código** que recibiste por email
3. **Crea un usuario administrador:**
   - Username: `admin`
   - Password: `admin123` (o la que prefieras)
4. **Espera** a que se descarguen los plugins (⏳ 10-30 minutos)

> 💡 **Tip:** No cierres el navegador mientras se descargan los plugins

---

### **Paso 9: Crear tu Primer Escaneo**

#### **Objetivos del Laboratorio:**
- `10.10.0.20` - Metasploitable (SSH: msfadmin/msfadmin)
- `10.10.0.21` - DVWA (Web: admin/password)
- `10.10.0.30` - Windows Target

#### **Crear Escaneo:**

1. En Nessus, ve a **"Scans"** → **"New Scan"**
2. Selecciona **"Basic Network Scan"**
3. **Configura:**
   - **Name:** `Laboratorio - Módulo 4`
   - **Targets:** 
     ```
     10.10.0.20
     10.10.0.21
     10.10.0.30
     ```
   - O en una línea: `10.10.0.20,10.10.0.21,10.10.0.30`
4. **Launch** (Lanzar el escaneo)
5. **Espera** 5-15 minutos a que termine

#### **Ver Resultados:**
- Clic en el escaneo completado
- Explora:
  - **Vulnerabilities** (vulnerabilidades encontradas)
  - **Hosts** (información por objetivo)
  - **History** (historial de escaneos)

#### **Exportar Reportes:**
1. Clic en el escaneo
2. **Export** → Selecciona formato:
   - **PDF** - Para presentaciones
   - **HTML** - Para revisar en navegador
   - **CSV** - Para análisis en Excel

---

## 🔐 Escaneo Credentialed (Avanzado)

Para un escaneo más profundo con credenciales SSH:

1. En la configuración del escaneo, ve a **"Credentials"**
2. **SSH** → **Add**
3. Configura:
   - **Username:** `msfadmin`
   - **Password:** `msfadmin`
   - **Authentication Method:** `Password`
4. **Guardar** y ejecutar el escaneo

---

## 🛠️ Troubleshooting (Solución de Problemas)

### ❌ Error: "No se puede acceder a https://localhost:8834"

**Solución:**
```powershell
# Verificar que el contenedor esté corriendo
docker ps | findstr nessus

# Verificar que Nessus esté corriendo
docker exec nessus-lab ps aux | findstr nessusd

# Si no está corriendo, iniciarlo:
docker exec nessus-lab /opt/nessus/sbin/nessusd

# Reiniciar contenedor si es necesario
docker-compose restart nessus
```

---

### ❌ Error: "Container is not running"

**Solución:**
```powershell
# Iniciar el contenedor
docker-compose up -d nessus

# Ver logs para diagnosticar
docker logs nessus-lab
```

---

### ❌ Error: "No such file or directory" al copiar .deb

**Solución:**
```powershell
# Verificar que el archivo exista
dir C:\Users\TU_USUARIO\Downloads\Nessus*.deb

# Copiar desde la carpeta actual si lo moviste
docker cp Nessus-10.10.0-debian10_amd64.deb nessus-lab:/tmp/Nessus.deb
```

---

### ❌ Los objetivos no responden (10.10.0.20-30)

**Solución:**
```powershell
# Verificar que los contenedores objetivo estén corriendo
docker ps

# Verificar conectividad desde Nessus
docker exec nessus-lab ping -c 2 10.10.0.20
docker exec nessus-lab ping -c 2 10.10.0.21
docker exec nessus-lab ping -c 2 10.10.0.30

# Si no responden, reiniciar todos los contenedores
docker-compose restart
```

---

## 📊 Verificación Completa

```powershell
# 1. Contenedores corriendo
docker-compose ps

# 2. Nessus instalado
docker exec nessus-lab ls -la /opt/nessus/sbin/nessusd

# 3. Nessus corriendo
docker exec nessus-lab ps aux | findstr nessusd

# 4. Puerto 8834 abierto
netstat -ano | findstr 8834

# 5. Conectividad con objetivos
docker exec kali-lab nmap -sn 10.10.0.20-30
```

---

## 🎯 Checklist de Instalación

- [ ] Docker y Docker Compose instalados
- [ ] Archivo `.deb` de Nessus descargado
- [ ] Contenedores Docker iniciados (`docker-compose up -d`)
- [ ] Archivo `.deb` copiado al contenedor
- [ ] Nessus instalado en el contenedor
- [ ] Servicio Nessus iniciado
- [ ] Acceso a `https://localhost:8834` funcionando
- [ ] Código de activación obtenido
- [ ] Nessus activado y configurado
- [ ] Plugins descargados (puede tardar 30 minutos)
- [ ] Primer escaneo ejecutado exitosamente
- [ ] Reportes exportados

---

## 📚 Recursos Adicionales

- **Documentación oficial:** https://docs.tenable.com/nessus/
- **Código Essentials gratis:** https://www.tenable.com/products/nessus/nessus-essentials
- **Plugin database:** https://www.tenable.com/plugins
- **Guía de usuario:** https://docs.tenable.com/nessus/Content/GettingStarted.htm

---

## 💡 Notas para el Equipo

- El archivo `.deb` **NO se incluye en el repositorio** por restricciones de licencia
- Cada persona debe descargar su propia copia desde el sitio oficial de Tenable
- El código de activación es **gratuito** y se obtiene en 2 minutos
- La descarga de plugins tarda 10-30 minutos la **primera vez**
- Los escaneos pueden tardar 5-15 minutos dependiendo de los objetivos

---

## 🎉 ¡Listo!

Ahora tienes **Nessus REAL** funcionando en Docker y puedes:
- ✅ Realizar escaneos de vulnerabilidades
- ✅ Crear políticas personalizadas
- ✅ Exportar reportes profesionales
- ✅ Escaneos credentialed y non-credentialed
- ✅ Completar el Módulo 4 del laboratorio
