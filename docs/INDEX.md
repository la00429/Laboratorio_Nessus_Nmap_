# 📚 Índice de Documentación - Laboratorio Nmap + Nessus

Esta es la documentación completa del laboratorio de escaneo de vulnerabilidades. Elige la opción que mejor se adapte a tus necesidades.

## 🚀 Inicio Rápido

### ¿No sabes qué opción elegir?
- **[Comparación Docker vs VMs](COMPARISON.md)** - Guía completa para decidir

### Si eliges Docker (Recomendado para estudiantes)
- **[Inicio Rápido Docker](QUICKSTART.md)** - Setup en 10 minutos
- **[Configuración Completa Docker](DOCKER_SETUP.md)** - Documentación detallada

### Si eliges Máquinas Virtuales (Recomendado para profesionales)
- **[Guía Original](../guia.md)** - Instrucciones completas para VMs
- **[Esquema de Red](../esquema.dot)** - Diagrama de arquitectura

## 📋 Documentación Principal

### README Principal
- **[README.MD](../README.MD)** - Guía completa del laboratorio (Docker + VMs)

### Arquitectura y Diseño
- **[Esquema de Red](../esquema.dot)** - Diagrama Graphviz de la arquitectura
- **[Arquitectura Docker](../docker-architecture.dot)** - Diagrama específico para Docker

## 🐳 Documentación Docker

### Configuración y Setup
- **[Configuración Completa](DOCKER_SETUP.md)** - Guía detallada de Docker
- **[Inicio Rápido](QUICKSTART.md)** - Setup express en 10 minutos
- **[Comparación](COMPARISON.md)** - Docker vs VMs

### Archivos de Configuración
- **[docker-compose.yml](../docker-compose.yml)** - Configuración principal
- **[env.example](../env.example)** - Variables de entorno
- **[setup.sh](../setup.sh)** - Script de configuración automática
- **[Makefile](../Makefile)** - Comandos útiles

### Contenedores
- **[Kali Linux](../containers/kali/)** - Herramientas de escaneo
- **[Nessus](../containers/nessus/)** - Escáner de vulnerabilidades
- **[Metasploitable](../containers/metasploitable/)** - Sistema vulnerable
- **[DVWA](../containers/dvwa/)** - Aplicación web vulnerable
- **[Windows Target](../containers/windows-target/)** - Simulador Windows

## 🖥️ Documentación Máquinas Virtuales

### Guía Principal
- **[Guía Original](../guia.md)** - Instrucciones completas para VMs
- **[Esquema de Red](../esquema.dot)** - Diagrama de arquitectura VM

### Configuración de VMs
- Configuración de VirtualBox/VMware
- Configuración de red host-only
- Instalación de sistemas operativos
- Configuración de servicios

## 🛠️ Scripts y Herramientas

### Scripts de Automatización
- **[parse_nmap_xml.py](../scripts/parse_nmap_xml.py)** - Parser de resultados Nmap
- **[import_nmap_to_nessus.sh](../scripts/import_nmap_to_nessus.sh)** - Integración con Nessus
- **[docker-lab-helper.py](../scripts/docker-lab-helper.py)** - Gestión del laboratorio Docker

### Scripts NSE
- **[my-banner.nse](../scripts/my-banner.nse)** - Script NSE de ejemplo
- **[Directorio NSE](../nse/)** - Scripts NSE personalizados

## 📊 Ejercicios y Módulos

### Módulo 1: Nmap Básico
- Reconocimiento de red
- Escaneo de puertos
- Detección de servicios
- Detección de versiones

### Módulo 2: NSE (Nmap Scripting Engine)
- Scripts de vulnerabilidad
- Scripts personalizados
- Categorías de scripts

### Módulo 3: Automatización
- Procesamiento con Python
- Integración de herramientas
- Generación de reportes

### Módulo 4: Nessus
- Configuración de políticas
- Escaneos credentialed/non-credentialed
- Análisis de plugins
- Correlación de resultados

## 📈 Reportes y Análisis

### Formatos de Salida
- XML (Nmap)
- CSV (Procesado)
- JSON (Procesado)
- PDF/HTML (Nessus)

### Correlación de Datos
- Nmap → Nessus
- Priorización de vulnerabilidades
- Análisis de CVSS

## 🔒 Seguridad y Ética

### Consideraciones de Seguridad
- Aislamiento del laboratorio
- Gestión de credenciales
- Monitoreo y logging
- Buenas prácticas

### Aspectos Éticos
- Autorización para escaneos
- Uso responsable de herramientas
- Documentación de pruebas

## 🆘 Soporte y Resolución de Problemas

### Problemas Comunes
- Conectividad de red
- Recursos del sistema
- Configuración de servicios
- Permisos y credenciales

### Comandos de Ayuda
```bash
# Docker
make help                    # Ver todos los comandos
make status                  # Estado del laboratorio
docker-compose logs          # Ver logs

# VMs
# Consultar guia.md para comandos específicos
```

### Logs y Debugging
- Logs de Docker: `docker-compose logs`
- Logs de VMs: Logs del sistema operativo
- Logs de aplicaciones: Archivos de log específicos

## 📞 Contacto y Contribuciones

### Reportar Problemas
- Crear issue en GitHub
- Incluir información del entorno
- Adjuntar logs relevantes

### Contribuir
- Fork del repositorio
- Crear rama para nueva funcionalidad
- Hacer commit de cambios
- Crear Pull Request

## 📄 Licencia

Este laboratorio está diseñado únicamente para fines educativos. Ver archivo `LICENSE` para más detalles.

---

## 🗺️ Navegación Rápida

### Para Estudiantes (Docker)
1. [Comparación](COMPARISON.md) → [Inicio Rápido](QUICKSTART.md) → [Configuración](DOCKER_SETUP.md)

### Para Profesionales (VMs)
1. [Comparación](COMPARISON.md) → [Guía Original](../guia.md) → [Esquema](../esquema.dot)

### Para Instructores
1. [README Principal](../README.MD) → [Comparación](COMPARISON.md) → Documentación específica

### Para Desarrolladores
1. [Scripts](../scripts/) → [Contenedores](../containers/) → [Makefile](../Makefile)

---

**¡Bienvenido al laboratorio de escaneo de vulnerabilidades!** 🎉

> Documentación mantenida por el equipo H5 - Redes y Seguridad
