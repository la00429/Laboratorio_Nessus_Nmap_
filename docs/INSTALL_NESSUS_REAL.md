# 🚀 Instalación de Nessus REAL en Docker

Esta guía te ayudará a instalar **Nessus real** en tu laboratorio Docker para completar el Módulo 4.

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Contenedores del laboratorio corriendo
- Conexión a internet (para descargar Nessus)
- ~2GB de espacio en disco

## ⚡ Instalación Rápida (5 pasos)

### **Paso 1: Descargar Nessus**

1. Ve a: https://www.tenable.com/downloads/nessus
2. Selecciona **"Nessus"** (no Nessus Agent)
3. Selecciona versión: **Ubuntu (64-bit)**
4. Descarga: `Nessus-[version]-ubuntu1604_amd64.deb`
5. Guarda el archivo en la carpeta del proyecto

**Ejemplo de archivo:**
```
Nessus-10.8.3-ubuntu1604_amd64.deb
```

### **Paso 2: Reconstruir el Contenedor**

Primero, vamos a reconstruir el contenedor con el nuevo Dockerfile:

```powershell
# Detener el contenedor actual
docker-compose stop nessus

# Eliminar el contenedor anterior
docker-compose rm -f nessus

# Reconstruir la imagen
docker-compose build --no-cache nessus

# Iniciar el contenedor
docker-compose up -d nessus
```

### **Paso 3: Copiar e Instalar Nessus**

**Opción A: Usando el script de instalación (RECOMENDADO)**

```powershell
# En PowerShell
.\scripts\install_nessus_real.ps1 manual .\Nessus-10.8.3-ubuntu1604_amd64.deb
```

**Opción B: Instalación manual**

```powershell
# 1. Copiar archivo al contenedor
docker cp Nessus-10.8.3-ubuntu1604_amd64.deb nessus-lab:/tmp/

# 2. Instalar dentro del contenedor
docker exec -it nessus-lab bash
dpkg -i /tmp/Nessus-10.8.3-ubuntu1604_amd64.deb
apt-get install -f -y
rm /tmp/Nessus-*.deb
exit

# 3. Reiniciar contenedor
docker-compose restart nessus
```

### **Paso 4: Iniciar Nessus**

```powershell
# Iniciar el servicio de Nessus
docker exec nessus-lab /opt/nessus/sbin/nessusd

# Ver logs
docker logs -f nessus-lab
```

### **Paso 5: Configurar Nessus**

1. Abre tu navegador
2. Ve a: `https://localhost:8834`
3. Acepta el certificado SSL (es seguro en localhost)
4. Selecciona **"Nessus Essentials"**
5. Crea usuario administrador:
   - Usuario: `admin`
   - Contraseña: `admin123`
   - Email: tu email
6. Obtén código de activación:
   - Ve a: https://www.tenable.com/products/nessus/nessus-essentials
   - Regístrate con tu email
   - Recibirás un código como: `XXXX-XXXX-XXXX-XXXX-XXXX`
7. Ingresa el código en Nessus
8. Espera a que se descarguen los plugins (10-30 minutos)

## ✅ Verificación de Instalación

### Verificar que Nessus está corriendo

```powershell
# Ver procesos de Nessus
docker exec nessus-lab ps aux | grep nessusd

# Ver logs
docker exec nessus-lab tail -f /opt/nessus/var/nessus/logs/nessusd.messages
```

### Verificar conectividad con objetivos

```powershell
# Desde el contenedor de Nessus
docker exec nessus-lab bash -c "
for ip in 10.10.0.20 10.10.0.21 10.10.0.30; do
    ping -c 1 \$ip && echo '✓ \$ip accesible' || echo '✗ \$ip no accesible'
done
"
```

## 🎯 Configuración del Módulo 4

### Crear Primera Política de Escaneo

1. En Nessus, ve a **"Policies"** > **"New Policy"**
2. Selecciona **"Basic Network Scan"**
3. Configura:
   - **Name**: `Laboratorio - Basic Scan`
   - **Description**: `Escaneo básico del laboratorio`
   - **Folder**: `My Scans`

### Configurar Objetivos

En la pestaña **"Settings"** > **"Basic"**:
- **Targets**: 
  ```
  10.10.0.20
  10.10.0.21
  10.10.0.30
  ```

### Crear Primer Escaneo

1. Ve a **"Scans"** > **"New Scan"**
2. Selecciona la política creada
3. Configura:
   - **Name**: `Módulo 4 - Escaneo Inicial`
   - **Targets**: `10.10.0.20,10.10.0.21,10.10.0.30`
4. Haz clic en **"Launch"**

## 🔐 Escaneo Credentialed (Avanzado)

### Configurar Credenciales SSH

1. En la política de escaneo, ve a **"Credentials"**
2. Selecciona **"SSH"** > **"Add"**
3. Configura:
   - **Username**: `msfadmin`
   - **Password**: `msfadmin`
   - **Authentication method**: `Password`

### Aplicar Credenciales a Objetivos

1. En **"Settings"** > **"Credentials"**
2. Haz clic en **"SSH"**
3. Agrega credenciales para cada objetivo:
   - **10.10.0.20**: usuario `msfadmin`, contraseña `msfadmin`
   - **10.10.0.21**: usuario `root`, contraseña `password`

## 📊 Exportar Reportes

### Exportar en PDF

1. Ve a **"Scans"**
2. Selecciona el escaneo completado
3. Haz clic en **"Export"**
4. Selecciona **"PDF"**
5. Configura opciones:
   - **Report Type**: `Executive Summary` o `Detailed Vulnerabilities`
   - **Chapters**: Selecciona todas las opciones
6. Descarga el reporte

### Exportar en HTML

1. Repite los pasos anteriores
2. Selecciona **"HTML"** en lugar de PDF

### Exportar en CSV

1. Selecciona **"CSV"**
2. Útil para análisis en Excel o Python

## 🔧 Comandos Útiles

### Estado de Nessus

```powershell
# Ver si Nessus está corriendo
docker exec nessus-lab ps aux | grep nessusd

# Ver logs en tiempo real
docker logs -f nessus-lab

# Acceder al contenedor
docker exec -it nessus-lab bash
```

### Gestión de Nessus

```bash
# Dentro del contenedor

# Iniciar Nessus
/opt/nessus/sbin/nessusd

# Detener Nessus
/opt/nessus/sbin/nessusd -q

# Reiniciar Nessus
/opt/nessus/sbin/nessusd -R

# Ver estado
/opt/nessus/sbin/nessuscli status

# Crear usuario (CLI)
/opt/nessus/sbin/nessuscli adduser

# Activar licencia (CLI)
/opt/nessus/sbin/nessuscli fetch --register XXXX-XXXX-XXXX-XXXX-XXXX

# Actualizar plugins
/opt/nessus/sbin/nessuscli update
```

### Ayuda Rápida

```bash
# Dentro del contenedor
/opt/nessus/help.sh
```

## ❓ Troubleshooting

### Problema: No puedo acceder a https://localhost:8834

**Solución 1**: Verifica que Nessus esté corriendo
```powershell
docker exec nessus-lab ps aux | grep nessusd
```

**Solución 2**: Verifica el puerto
```powershell
docker ps | grep nessus
```

**Solución 3**: Reinicia el contenedor
```powershell
docker-compose restart nessus
```

### Problema: Certificado SSL inválido

**Solución**: En el navegador, haz clic en "Avanzado" > "Continuar a localhost"

### Problema: La descarga de plugins se queda estancada

**Solución**: Espera pacientemente. La primera descarga puede tomar 30+ minutos.

### Problema: No puedo escanear los objetivos

**Solución 1**: Verifica conectividad
```powershell
docker exec nessus-lab ping -c 3 10.10.0.20
```

**Solución 2**: Verifica que los contenedores objetivo estén corriendo
```powershell
docker ps
```

### Problema: "Nessus no está instalado"

**Solución**: Ejecuta la instalación manual:
```powershell
.\scripts\install_nessus_real.ps1 manual .\Nessus-*.deb
```

## 📚 Recursos Adicionales

- **Documentación Oficial**: https://docs.tenable.com/nessus/
- **Plugin Database**: https://www.tenable.com/plugins
- **Nessus Essentials**: https://www.tenable.com/products/nessus/nessus-essentials
- **Guía de Usuario**: https://docs.tenable.com/nessus/Content/GettingStarted.htm

## ✅ Checklist Final

- [ ] Nessus descargado
- [ ] Contenedor reconstruido
- [ ] Nessus instalado en el contenedor
- [ ] Servicio Nessus iniciado
- [ ] Interfaz web accesible (https://localhost:8834)
- [ ] Usuario administrador creado
- [ ] Código de activación ingresado
- [ ] Plugins descargados
- [ ] Política de escaneo creada
- [ ] Primer escaneo ejecutado
- [ ] Reporte exportado

## 🎉 ¡Listo!

Ahora tienes **Nessus real** funcionando en tu laboratorio Docker. Puedes proceder con los ejercicios del Módulo 4.

**Siguiente paso**: Crear tu primera política de escaneo y ejecutar un escaneo completo de vulnerabilidades.
