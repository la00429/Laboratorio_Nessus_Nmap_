# Usar una imagen base de Windows Server Core
# Nota: En un entorno real, usarías mcr.microsoft.com/windows/servercore:ltsc2022
# Para este ejemplo, usamos una imagen Linux que simula servicios Windows
FROM ubuntu:20.04

# Metadatos
LABEL maintainer="Laboratorio Nmap+Nessus"
LABEL description="Windows Target Simulator - Para escaneos credentialed"

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV WIN_PASSWORD=Password123

# Instalar servicios que simulan Windows
RUN apt-get update && apt-get install -y \
    # Samba para simular SMB/CIFS
    samba \
    samba-common-bin \
    # OpenSSH Server
    openssh-server \
    # Herramientas de red
    netcat-openbsd \
    tcpdump \
    nmap \
    # Servicios adicionales
    xinetd \
    telnetd \
    # Limpieza
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar usuario Windows simulado
RUN useradd -m -s /bin/bash administrator && \
    echo "administrator:$WIN_PASSWORD" | chpasswd && \
    usermod -aG sudo administrator

# Configurar Samba
RUN echo '[homes]' >> /etc/samba/smb.conf && \
    echo '   comment = Home Directories' >> /etc/samba/smb.conf && \
    echo '   browseable = yes' >> /etc/samba/smb.conf && \
    echo '   read only = no' >> /etc/samba/smb.conf && \
    echo '   create mask = 0755' >> /etc/samba/smb.conf && \
    echo '[shared]' >> /etc/samba/smb.conf && \
    echo '   comment = Shared Folder' >> /etc/samba/smb.conf && \
    echo '   path = /shared' >> /etc/samba/smb.conf && \
    echo '   browseable = yes' >> /etc/samba/smb.conf && \
    echo '   read only = no' >> /etc/samba/smb.conf && \
    echo '   guest ok = yes' >> /etc/samba/smb.conf && \
    mkdir -p /shared && \
    chmod 777 /shared

# Configurar usuario Samba
RUN (echo "Password123"; echo "Password123") | smbpasswd -a administrator

# Configurar SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd

# Configurar servicios xinetd
RUN echo 'service telnet' > /etc/xinetd.d/telnet && \
    echo '{' >> /etc/xinetd.d/telnet && \
    echo '    socket_type = stream' >> /etc/xinetd.d/telnet && \
    echo '    wait = no' >> /etc/xinetd.d/telnet && \
    echo '    user = root' >> /etc/xinetd.d/telnet && \
    echo '    server = /usr/sbin/in.telnetd' >> /etc/xinetd.d/telnet && \
    echo '    log_on_success += DURATION USERID' >> /etc/xinetd.d/telnet && \
    echo '    log_on_failure += USERID' >> /etc/xinetd.d/telnet && \
    echo '    disable = no' >> /etc/xinetd.d/telnet && \
    echo '}' >> /etc/xinetd.d/telnet

# Crear archivos de prueba
RUN echo "Windows Target Simulator" > /shared/readme.txt && \
    echo "Este es un simulador de Windows para pruebas de escaneo credentialed" >> /shared/readme.txt

# Script de inicio
COPY containers/windows-target/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    sed -i 's/\r$//' /entrypoint.sh

# Exponer puertos
EXPOSE 22 135 139 445 3389 1433

# Punto de entrada
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
