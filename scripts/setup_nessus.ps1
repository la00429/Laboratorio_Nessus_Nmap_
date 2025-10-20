# Script de instalación automática de Nessus en Docker
# Para el Laboratorio Nmap + Nessus

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "INSTALACIÓN AUTOMÁTICA DE NESSUS EN DOCKER" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Buscar archivo .deb de Nessus
Write-Host "[*] Buscando archivo Nessus .deb..." -ForegroundColor Yellow

$nessusFile = $null
$searchPaths = @(
    "$env:USERPROFILE\Downloads\Nessus*.deb",
    ".\Nessus*.deb",
    "..\Nessus*.deb"
)

foreach ($path in $searchPaths) {
    $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $nessusFile = $found.FullName
        break
    }
}

if (-not $nessusFile) {
    Write-Host "[ERROR] No se encontró el archivo Nessus .deb" -ForegroundColor Red
    Write-Host ""
    Write-Host "PASOS PARA DESCARGAR NESSUS:" -ForegroundColor Yellow
    Write-Host "1. Ve a: https://www.tenable.com/downloads/nessus" -ForegroundColor White
    Write-Host "2. Selecciona: Debian 10 (64-bit) o Ubuntu (64-bit)" -ForegroundColor White
    Write-Host "3. Descarga el archivo .deb" -ForegroundColor White
    Write-Host "4. Guárdalo en la carpeta Downloads" -ForegroundColor White
    Write-Host "5. Ejecuta este script nuevamente" -ForegroundColor White
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "[OK] Archivo encontrado: $nessusFile" -ForegroundColor Green
Write-Host ""

# Verificar que el contenedor esté corriendo
Write-Host "[*] Verificando contenedor nessus-lab..." -ForegroundColor Yellow
$container = docker ps --filter "name=nessus-lab" --format "{{.Names}}"

if (-not $container) {
    Write-Host "[WARN] Contenedor nessus-lab no está corriendo" -ForegroundColor Yellow
    Write-Host "Iniciando contenedor..." -ForegroundColor White
    docker-compose up -d nessus
    Start-Sleep -Seconds 5
}

Write-Host "[OK] Contenedor listo" -ForegroundColor Green
Write-Host ""

# Copiar archivo al contenedor
Write-Host "[*] Copiando archivo al contenedor..." -ForegroundColor Yellow
docker cp $nessusFile nessus-lab:/tmp/Nessus.deb

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al copiar archivo" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Archivo copiado" -ForegroundColor Green
Write-Host ""

# Instalar Nessus
Write-Host "[*] Instalando Nessus..." -ForegroundColor Yellow
docker exec nessus-lab dpkg -i /tmp/Nessus.deb

if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARN] Instalando dependencias..." -ForegroundColor Yellow
    docker exec nessus-lab apt-get install -f -y
}

Write-Host "[OK] Nessus instalado" -ForegroundColor Green
Write-Host ""

# Iniciar Nessus
Write-Host "[*] Iniciando servicio Nessus..." -ForegroundColor Yellow
Start-Job -ScriptBlock {
    docker exec nessus-lab /opt/nessus/sbin/nessusd
} | Out-Null

Start-Sleep -Seconds 10

# Verificar que esté corriendo
$nessusRunning = docker exec nessus-lab ps aux | Select-String "nessusd"

if ($nessusRunning) {
    Write-Host "[OK] Nessus iniciado correctamente" -ForegroundColor Green
} else {
    Write-Host "[WARN] Nessus podría estar iniciando..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "INSTALACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ACCEDE A NESSUS:" -ForegroundColor Green
Write-Host "   https://localhost:8834" -ForegroundColor Cyan
Write-Host ""
Write-Host "CONFIGURACIÓN INICIAL:" -ForegroundColor Green
Write-Host "   1. Selecciona: Nessus Professional" -ForegroundColor White
Write-Host "   2. Código gratis: https://www.tenable.com/products/nessus/nessus-essentials" -ForegroundColor White
Write-Host "   3. Usuario: admin / Password: admin123" -ForegroundColor White
Write-Host "   4. Espera descarga de plugins (10-30 min)" -ForegroundColor White
Write-Host ""
Write-Host "TARGETS DEL LABORATORIO:" -ForegroundColor Green
Write-Host "   10.10.0.20,10.10.0.21,10.10.0.30" -ForegroundColor Cyan
Write-Host ""
Write-Host "Guía completa: docs\INSTALACION_NESSUS_DOCKER.md" -ForegroundColor Yellow
Write-Host ""

# Abrir navegador
$openBrowser = Read-Host "¿Abrir Nessus en el navegador? (s/n)"
if ($openBrowser -eq "s" -or $openBrowser -eq "S") {
    Start-Process "https://localhost:8834"
}

Write-Host "¡Listo! Presiona Enter para salir" -ForegroundColor Green
Read-Host
