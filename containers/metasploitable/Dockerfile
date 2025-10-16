FROM ubuntu:14.04

# Metadatos
LABEL maintainer="Laboratorio Nmap+Nessus"
LABEL description="Metasploitable2 - Sistema vulnerable para pruebas"

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar sistema e instalar servicios vulnerables
RUN apt-get update && apt-get install -y \
    # Servicios básicos
    openssh-server \
    vsftpd \
    telnetd \
    postfix \
    bind9 \
    apache2 \
    mysql-server \
    postgresql \
    # Herramientas de red
    netcat-openbsd \
    tcpdump \
    nmap \
    # Servicios adicionales
    xinetd \
    # Limpieza
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar SSH vulnerable
RUN echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd

# Configurar FTP vulnerable
RUN echo 'anonymous' >> /etc/ftpusers && \
    sed -i 's/#local_enable=YES/local_enable=YES/' /etc/vsftpd.conf && \
    sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf && \
    sed -i 's/#local_umask=022/local_umask=022/' /etc/vsftpd.conf

# Configurar Apache vulnerable
RUN echo '<html><body><h1>Metasploitable2 Web Server</h1></body></html>' > /var/www/html/index.html && \
    chown www-data:www-data /var/www/html/index.html

# Configurar MySQL vulnerable
RUN service mysql start && \
    mysql -e "CREATE DATABASE metasploit;" && \
    mysql -e "CREATE USER 'msf'@'%' IDENTIFIED BY 'msf';" && \
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'msf'@'%';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Configurar PostgreSQL vulnerable
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE USER msf;" && \
    sudo -u postgres psql -c "ALTER USER msf PASSWORD 'msf';" && \
    sudo -u postgres psql -c "CREATE DATABASE msf;" && \
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE msf TO msf;"

# Crear usuarios vulnerables
RUN useradd -m -s /bin/bash msfadmin && \
    echo 'msfadmin:msfadmin' | chpasswd && \
    usermod -aG sudo msfadmin

# Configurar servicios vulnerables adicionales
RUN echo 'service vsftpd' > /etc/xinetd.d/vsftpd && \
    echo '{' >> /etc/xinetd.d/vsftpd && \
    echo '    socket_type = stream' >> /etc/xinetd.d/vsftpd && \
    echo '    wait = no' >> /etc/xinetd.d/vsftpd && \
    echo '    user = root' >> /etc/xinetd.d/vsftpd && \
    echo '    server = /usr/sbin/vsftpd' >> /etc/xinetd.d/vsftpd && \
    echo '    log_on_success += DURATION USERID' >> /etc/xinetd.d/vsftpd && \
    echo '    log_on_failure += USERID' >> /etc/xinetd.d/vsftpd && \
    echo '    disable = no' >> /etc/xinetd.d/vsftpd && \
    echo '}' >> /etc/xinetd.d/vsftpd

# Script de inicio
COPY containers/metasploitable/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exponer puertos vulnerables
EXPOSE 21 22 23 25 53 80 110 139 445 993 995 1723 3306 5432 5900 6001

# Punto de entrada
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
