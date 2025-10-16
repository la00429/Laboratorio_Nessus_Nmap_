#!/usr/bin/env python3
"""
Helper script para el laboratorio Docker Nmap + Nessus
Proporciona funciones de utilidad para trabajar con los contenedores
"""

import subprocess
import json
import sys
import os
import time
import requests
from datetime import datetime

class DockerLabHelper:
    def __init__(self):
        self.containers = {
            'kali': 'kali-lab',
            'nessus': 'nessus-lab', 
            'metasploitable': 'metasploitable-lab',
            'dvwa': 'dvwa-lab',
            'windows-target': 'windows-target-lab'
        }
        
        self.network_config = {
            'subnet': '10.10.0.0/24',
            'gateway': '10.10.0.1',
            'containers': {
                'kali': '10.10.0.10',
                'metasploitable': '10.10.0.20',
                'dvwa': '10.10.0.21',
                'windows-target': '10.10.0.30',
                'nessus': '10.10.0.100'
            }
        }

    def run_command(self, command, capture_output=True):
        """Ejecuta un comando y retorna el resultado"""
        try:
            if capture_output:
                result = subprocess.run(command, shell=True, capture_output=True, text=True)
                return result.returncode, result.stdout, result.stderr
            else:
                result = subprocess.run(command, shell=True)
                return result.returncode, "", ""
        except Exception as e:
            return 1, "", str(e)

    def check_docker_status(self):
        """Verifica el estado de Docker y los contenedores"""
        print("=== VERIFICANDO ESTADO DEL LABORATORIO ===")
        
        # Verificar Docker
        rc, stdout, stderr = self.run_command("docker --version")
        if rc == 0:
            print(f"✓ Docker: {stdout.strip()}")
        else:
            print(f"✗ Docker no disponible: {stderr}")
            return False
        
        # Verificar Docker Compose
        rc, stdout, stderr = self.run_command("docker-compose --version")
        if rc == 0:
            print(f"✓ Docker Compose: {stdout.strip()}")
        else:
            print(f"✗ Docker Compose no disponible: {stderr}")
            return False
        
        print("\n=== ESTADO DE CONTENEDORES ===")
        
        # Verificar cada contenedor
        for name, container in self.containers.items():
            rc, stdout, stderr = self.run_command(f"docker ps -f name={container} --format 'table {{.Names}}\\t{{.Status}}\\t{{.Ports}}'")
            if rc == 0 and container in stdout:
                print(f"✓ {name}: {container} - Ejecutándose")
            else:
                print(f"✗ {name}: {container} - No ejecutándose")
        
        return True

    def start_lab(self):
        """Inicia el laboratorio completo"""
        print("=== INICIANDO LABORATORIO ===")
        
        # Verificar si docker-compose.yml existe
        if not os.path.exists("docker-compose.yml"):
            print("✗ docker-compose.yml no encontrado")
            return False
        
        # Iniciar contenedores
        print("Iniciando contenedores...")
        rc, stdout, stderr = self.run_command("docker-compose up -d")
        
        if rc == 0:
            print("✓ Laboratorio iniciado correctamente")
            print("\nEsperando a que los servicios estén listos...")
            time.sleep(10)
            self.check_connectivity()
        else:
            print(f"✗ Error al iniciar laboratorio: {stderr}")
            return False
        
        return True

    def stop_lab(self):
        """Detiene el laboratorio"""
        print("=== DETENIENDO LABORATORIO ===")
        
        rc, stdout, stderr = self.run_command("docker-compose down")
        
        if rc == 0:
            print("✓ Laboratorio detenido correctamente")
        else:
            print(f"✗ Error al detener laboratorio: {stderr}")
        
        return rc == 0

    def check_connectivity(self):
        """Verifica la conectividad entre contenedores"""
        print("\n=== VERIFICANDO CONECTIVIDAD ===")
        
        # Verificar desde Kali a otros contenedores
        kali_container = self.containers['kali']
        
        for name, ip in self.network_config['containers'].items():
            if name == 'kali':
                continue
            
            rc, stdout, stderr = self.run_command(f"docker exec {kali_container} ping -c 1 -W 1 {ip}")
            if rc == 0:
                print(f"✓ Kali -> {name} ({ip}): Conectado")
            else:
                print(f"✗ Kali -> {name} ({ip}): No conectado")

    def show_lab_info(self):
        """Muestra información del laboratorio"""
        print("=== INFORMACIÓN DEL LABORATORIO ===")
        print(f"Red: {self.network_config['subnet']}")
        print(f"Gateway: {self.network_config['gateway']}")
        print("\nContenedores:")
        
        for name, ip in self.network_config['containers'].items():
            container_name = self.containers[name]
            print(f"  {name:15} -> {ip:15} ({container_name})")
        
        print("\n=== ACCESOS ===")
        print("SSH a Kali:")
        print("  ssh root@localhost -p 2222 (password: kali123)")
        print("  ssh labuser@localhost -p 2222 (password: lab123)")
        print()
        print("Nessus Web UI:")
        print("  https://localhost:8834")
        print("  Usuario: admin, Contraseña: admin123")
        print()
        print("DVWA Web UI:")
        print("  http://localhost:8180")
        print("  Usuario: admin, Contraseña: password")
        print()
        print("Metasploitable SSH:")
        print("  ssh root@localhost -p 2220 (password: password)")
        print("  ssh msfadmin@localhost -p 2220 (password: msfadmin)")

    def run_nmap_scan(self, target, scan_type="basic", output_file=None):
        """Ejecuta un escaneo Nmap desde Kali"""
        kali_container = self.containers['kali']
        
        if not output_file:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_file = f"scan_{target.replace('.', '_')}_{timestamp}"
        
        # Definir comandos de escaneo
        scan_commands = {
            "ping": f"nmap -sn {target}",
            "basic": f"nmap -sS -sV -oA /workspace/resultados/{output_file} {target}",
            "aggressive": f"nmap -A -T4 -oA /workspace/resultados/{output_file} {target}",
            "udp": f"nmap -sU -p 53,67,123,161,500 -oA /workspace/resultados/{output_file} {target}",
            "vuln": f"nmap -sS -sV --script=vuln -oA /workspace/resultados/{output_file} {target}"
        }
        
        if scan_type not in scan_commands:
            print(f"Tipo de escaneo no válido: {scan_type}")
            print(f"Tipos disponibles: {list(scan_commands.keys())}")
            return False
        
        command = scan_commands[scan_type]
        
        print(f"=== EJECUTANDO ESCANEO NMAP ===")
        print(f"Tipo: {scan_type}")
        print(f"Target: {target}")
        print(f"Comando: {command}")
        print(f"Archivo de salida: {output_file}")
        
        # Ejecutar escaneo
        rc, stdout, stderr = self.run_command(f"docker exec {kali_container} {command}")
        
        if rc == 0:
            print("✓ Escaneo completado")
            print(stdout)
            
            # Mostrar archivos generados
            rc, stdout, stderr = self.run_command(f"docker exec {kali_container} ls -la /workspace/resultados/{output_file}.*")
            if rc == 0:
                print(f"\nArchivos generados:")
                print(stdout)
        else:
            print(f"✗ Error en el escaneo: {stderr}")
        
        return rc == 0

    def check_nessus_status(self):
        """Verifica el estado de Nessus"""
        print("=== VERIFICANDO ESTADO DE NESSUS ===")
        
        nessus_url = "https://10.10.0.100:8834"
        
        try:
            # Verificar conectividad (ignorar certificados SSL)
            response = requests.get(nessus_url, verify=False, timeout=10)
            print(f"✓ Nessus Web UI accesible: {nessus_url}")
            print(f"  Estado HTTP: {response.status_code}")
        except requests.exceptions.RequestException as e:
            print(f"✗ Nessus Web UI no accesible: {e}")
            return False
        
        return True

    def interactive_mode(self):
        """Modo interactivo para el laboratorio"""
        print("=== MODO INTERACTIVO - LABORATORIO NMAP + NESSUS ===")
        print("Comandos disponibles:")
        print("  status    - Verificar estado del laboratorio")
        print("  start     - Iniciar laboratorio")
        print("  stop      - Detener laboratorio")
        print("  info      - Mostrar información del laboratorio")
        print("  scan      - Ejecutar escaneo Nmap")
        print("  nessus    - Verificar estado de Nessus")
        print("  help      - Mostrar esta ayuda")
        print("  quit      - Salir")
        print()
        
        while True:
            try:
                command = input("lab> ").strip().lower()
                
                if command == "quit" or command == "exit":
                    break
                elif command == "status":
                    self.check_docker_status()
                elif command == "start":
                    self.start_lab()
                elif command == "stop":
                    self.stop_lab()
                elif command == "info":
                    self.show_lab_info()
                elif command == "nessus":
                    self.check_nessus_status()
                elif command.startswith("scan"):
                    parts = command.split()
                    if len(parts) >= 2:
                        target = parts[1]
                        scan_type = parts[2] if len(parts) > 2 else "basic"
                        self.run_nmap_scan(target, scan_type)
                    else:
                        print("Uso: scan <target> [tipo]")
                        print("Tipos: ping, basic, aggressive, udp, vuln")
                elif command == "help":
                    print("Comandos: status, start, stop, info, scan, nessus, help, quit")
                else:
                    print(f"Comando no reconocido: {command}")
                    print("Escribe 'help' para ver comandos disponibles")
                
                print()
                
            except KeyboardInterrupt:
                print("\nSaliendo...")
                break
            except Exception as e:
                print(f"Error: {e}")

def main():
    helper = DockerLabHelper()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "status":
            helper.check_docker_status()
        elif command == "start":
            helper.start_lab()
        elif command == "stop":
            helper.stop_lab()
        elif command == "info":
            helper.show_lab_info()
        elif command == "interactive":
            helper.interactive_mode()
        else:
            print(f"Comando no reconocido: {command}")
            print("Comandos disponibles: status, start, stop, info, interactive")
    else:
        helper.interactive_mode()

if __name__ == "__main__":
    main()
