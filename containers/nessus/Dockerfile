FROM ubuntu:22.04

# Metadatos
LABEL maintainer="Laboratorio Nmap+Nessus"
LABEL description="Nessus Vulnerability Scanner"

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV NESSUS_ADMIN_PASSWORD=admin123
ENV NESSUS_HOME=/opt/nessus

# Actualizar sistema e instalar dependencias
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario nessus
RUN groupadd -r nessus && useradd -r -g nessus -d /opt/nessus -s /bin/bash nessus

# Crear directorios
RUN mkdir -p /opt/nessus/{bin,lib,var,etc,plugins,logs,imports} && \
    chown -R nessus:nessus /opt/nessus

# Descargar e instalar Nessus
# Nota: En un entorno real, necesitarías descargar la versión apropiada
# Aquí usamos una versión de prueba/desarrollo
RUN wget -q https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.7.0-ubuntu1404_amd64.deb \
    -O /tmp/nessus.deb && \
    dpkg -i /tmp/nessus.deb || apt-get install -f -y && \
    rm /tmp/nessus.deb

# Configurar Nessus
RUN /opt/nessus/sbin/nessuscli update --all || true

# Crear script de inicialización
COPY init-nessus.sh /init-nessus.sh
RUN chmod +x /init-nessus.sh

# Crear script de entrada
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exponer puertos
EXPOSE 8834

# Volúmenes
VOLUME ["/opt/nessus/var", "/opt/nessus/plugins", "/opt/nessus/imports"]

# Usuario
USER nessus

# Punto de entrada
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/nessus/sbin/nessusd", "-D"]
