FROM kalilinux/kali-rolling:latest

# Metadatos
LABEL maintainer="Laboratorio Nmap+Nessus"
LABEL description="Kali Linux con herramientas de escaneo y análisis"

# Actualizar sistema y instalar herramientas esenciales
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    # Herramientas de escaneo
    nmap \
    masscan \
    zmap \
    unicornscan \
    # Herramientas de red
    netcat-openbsd \
    netcat-traditional \
    socat \
    tcpdump \
    wireshark-common \
    # Herramientas de desarrollo
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    vim \
    nano \
    # Herramientas adicionales
    john \
    hydra \
    medusa \
    nikto \
    dirb \
    gobuster \
    # SSH server para acceso remoto
    openssh-server \
    # Limpieza
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar librerías Python adicionales
RUN pip3 install \
    python-nmap \
    requests \
    beautifulsoup4 \
    lxml \
    pandas \
    matplotlib \
    seaborn

# Configurar SSH
RUN echo 'root:kali123' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd

# Crear directorio de trabajo
WORKDIR /workspace

# Crear estructura de directorios
RUN mkdir -p /workspace/{resultados,scripts,nse,docs,reports}

# Copiar scripts personalizados
COPY scripts/ /workspace/scripts/
COPY nse/ /workspace/nse/

# Hacer ejecutables los scripts
RUN chmod +x /workspace/scripts/*.py /workspace/scripts/*.sh 2>/dev/null || true

# Crear usuario de trabajo
RUN useradd -m -s /bin/bash -u 1000 labuser && \
    echo 'labuser:lab123' | chpasswd && \
    chown -R labuser:labuser /workspace

# Exponer puertos
EXPOSE 22 8080

# Script de inicio
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Cambiar a usuario no-root
USER labuser

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
