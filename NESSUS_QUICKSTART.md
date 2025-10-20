# ⚡ Nessus en Docker - Inicio Rápido (2 minutos)

## ⚠️ ANTES DE EMPEZAR
**Descarga Nessus:** https://www.tenable.com/downloads/nessus  
Selecciona: **Debian 10 (64-bit)** → Guarda en Downloads

---

## 🚀 Instalación Automática

```powershell
# Desde la carpeta del proyecto, ejecuta:
.\scripts\setup_nessus.ps1
```

**El script hace todo automáticamente** ✅

---

## 🌐 Configurar

1. **Abre:** https://localhost:8834
2. **Código gratis:** https://www.tenable.com/products/nessus/nessus-essentials  
   (Te llega por email en 2 minutos)
3. **Usuario:** `admin` | **Password:** `admin123`
4. **Espera plugins:** 10-30 minutos ⏳

---

## 🎯 Primer Escaneo

**New Scan** → **Basic Network Scan**

**Targets:**
```
10.10.0.20,10.10.0.21,10.10.0.30
```

**Launch** → Espera 5-15 min → **Export PDF**

---

## 📖 Más Info

- **Guía completa:** [docs/INSTALACION_NESSUS_DOCKER.md](docs/INSTALACION_NESSUS_DOCKER.md)
- **README principal:** [README.MD](README.MD#paso-6-instalar-nessus-requerido-para-módulo-4)
- **Guía del laboratorio:** [guia.md](guia.md#módulo-4--nessus-teoría-y-práctica)