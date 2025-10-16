# 🚀 Guía de Inicio Rápido - Laboratorio Docker

Esta guía te permitirá tener el laboratorio funcionando en menos de 10 minutos.

## ⚡ Inicio Express

### 1. Verificar Prerrequisitos
```bash
# Verificar Docker
docker --version
docker-compose --version

# Verificar espacio disponible (mínimo 4GB)
df -h
```

### 2. Configurar Variables
```bash
# Copiar archivo de configuración
cp env.example .env

# Editar si es necesario (opcional)
nano .env
```

### 3. Iniciar Laboratorio
```bash
# Iniciar todos los contenedores
docker-compose up -d

# Verificar estado
docker-compose ps
```

### 4. Verificar Conectividad
```bash
# Usar el helper script
python3 scripts/docker-lab-helper.py status

# O verificar manualmente
docker exec kali-lab ping -c 1 10.10.0.20
```

## 🎯 Primeros Pasos

### Acceder a Kali Linux
```bash
ssh root@localhost -p 2222
# Password: kali123
```

### Ejecutar Primer Escaneo
```bash
# Desde Kali
nmap -sn 10.10.0.0/24
nmap -sS -sV 10.10.0.20
```

### Acceder a Nessus
1. Abrir navegador: https://localhost:8834
2. Usuario: `admin`
3. Contraseña: `admin123`
4. Crear política básica
5. Configurar escaneo

### Acceder a DVWA
1. Abrir navegador: http://localhost:8180
2. Usuario: `admin`
3. Contraseña: `password`
4. Configurar nivel de seguridad

## 🔧 Comandos Esenciales

### Gestión del Laboratorio
```bash
# Iniciar
docker-compose up -d

# Detener
docker-compose down

# Reiniciar
docker-compose restart

# Ver logs
docker-compose logs -f
```

### Acceso Rápido
```bash
# Kali SSH
ssh root@localhost -p 2222

# Ejecutar comando en Kali
docker exec kali-lab nmap -sn 10.10.0.0/24

# Ver logs de Nessus
docker logs nessus-lab
```

### Limpieza
```bash
# Detener y limpiar
docker-compose down

# Limpiar volúmenes (¡cuidado!)
docker-compose down -v
```

## 📋 Checklist de Verificación

- [ ] Docker y Docker Compose instalados
- [ ] Archivo `.env` configurado
- [ ] Contenedores iniciados (`docker-compose ps`)
- [ ] Kali accesible via SSH
- [ ] Nessus accesible via web (https://localhost:8834)
- [ ] DVWA accesible via web (http://localhost:8180)
- [ ] Conectividad entre contenedores
- [ ] Primer escaneo Nmap ejecutado

## 🚨 Problemas Comunes

### Contenedores no inician
```bash
# Ver logs
docker-compose logs

# Verificar recursos
docker stats

# Reiniciar Docker
sudo systemctl restart docker
```

### Nessus no carga
```bash
# Esperar más tiempo (Nessus tarda en iniciar)
sleep 60

# Verificar logs
docker logs nessus-lab

# Reiniciar Nessus
docker-compose restart nessus
```

### Problemas de red
```bash
# Verificar red Docker
docker network ls
docker network inspect lab-network

# Reiniciar red
docker-compose down
docker-compose up -d
```

## 🎓 Siguiente Paso

Una vez que tengas el laboratorio funcionando:

1. **Lee la documentación completa**: `docs/DOCKER_SETUP.md`
2. **Ejecuta los ejercicios**: Sigue la guía original `guia.md`
3. **Usa el helper script**: `python3 scripts/docker-lab-helper.py interactive`
4. **Explora los scripts**: Revisa `scripts/` para automatización

---

¡El laboratorio está listo! 🎉
