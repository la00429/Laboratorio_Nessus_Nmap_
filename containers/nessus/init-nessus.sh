#!/bin/bash
# Script de inicialización de Nessus

echo "Inicializando Nessus..."

# Verificar si Nessus está instalado
if [ -f "/opt/nessus/sbin/nessusd" ]; then
    echo "Nessus encontrado. Iniciando..."
    /opt/nessus/sbin/nessusd
else
    echo "Nessus no está instalado."
    echo "Por favor, instala Nessus siguiendo las instrucciones en /opt/nessus/INSTALL.txt"
fi