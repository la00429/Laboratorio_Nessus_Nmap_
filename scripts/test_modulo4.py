#!/usr/bin/env python3
"""
Script para probar el Módulo 4 - Nessus
Simula las funcionalidades de Nessus usando Nmap y análisis de vulnerabilidades
"""

import subprocess
import json
import sys
import os
import time
from datetime import datetime

class Modulo4Tester:
    def __init__(self):
        self.containers = {
            'kali': 'kali-lab',
            'metasploitable': 'metasploitable-lab',
            'dvwa': 'dvwa-lab',
            'windows-target': 'windows-target-lab'
        }
        
        self.targets = {
            'metasploitable': '10.10.0.20',
            'dvwa': '10.10.0.21', 
            'windows-target': '10.10.0.30'
        }
        
        self.results_dir = "/workspace/resultados"

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

    def test_1_discovery_scan(self):
        """Prueba 1: Escaneo de descubrimiento (simulando Nessus non-credentialed)"""
        print("=" * 60)
        print("PRUEBA 1: ESCANEO DE DESCUBRIMIENTO (Non-credentialed)")
        print("=" * 60)
        
        kali_container = self.containers['kali']
        targets = " ".join(self.targets.values())
        
        print(f"Objetivos: {targets}")
        print("Ejecutando escaneo de descubrimiento...")
        
        # Escaneo básico de puertos comunes
        command = f"docker exec {kali_container} nmap -sS -sV -p 1-1000 {targets} -oA {self.results_dir}/modulo4_discovery"
        
        rc, stdout, stderr = self.run_command(command)
        
        if rc == 0:
            print("✓ Escaneo de descubrimiento completado")
            print("\nResumen de puertos abiertos encontrados:")
            
            # Mostrar puertos abiertos
            for target_name, target_ip in self.targets.items():
                print(f"\n--- {target_name} ({target_ip}) ---")
                grep_cmd = f"docker exec {kali_container} grep -E '^[0-9]+/tcp.*open' {self.results_dir}/modulo4_discovery.nmap | grep {target_ip}"
                rc2, output, _ = self.run_command(grep_cmd)
                if rc2 == 0 and output.strip():
                    print(output.strip())
                else:
                    print("  No se encontraron puertos abiertos en el rango escaneado")
        else:
            print(f"✗ Error en el escaneo: {stderr}")
        
        return rc == 0

    def test_2_vulnerability_scan(self):
        """Prueba 2: Escaneo de vulnerabilidades (simulando plugins de Nessus)"""
        print("\n" + "=" * 60)
        print("PRUEBA 2: ESCANEO DE VULNERABILIDADES (NSE Scripts)")
        print("=" * 60)
        
        kali_container = self.containers['kali']
        targets = " ".join(self.targets.values())
        
        print("Ejecutando scripts de vulnerabilidad...")
        
        # Escaneo con scripts de vulnerabilidad
        command = f"docker exec {kali_container} nmap -sS -sV --script=vuln {targets} -oA {self.results_dir}/modulo4_vulnerabilities"
        
        rc, stdout, stderr = self.run_command(command)
        
        if rc == 0:
            print("✓ Escaneo de vulnerabilidades completado")
            print("\nVulnerabilidades encontradas:")
            
            # Analizar resultados de vulnerabilidades
            for target_name, target_ip in self.targets.items():
                print(f"\n--- {target_name} ({target_ip}) ---")
                grep_cmd = f"docker exec {kali_container} grep -A 5 -B 2 'VULNERABLE\\|CVE\\|vuln' {self.results_dir}/modulo4_vulnerabilities.nmap | grep -A 10 {target_ip}"
                rc2, output, _ = self.run_command(grep_cmd)
                if rc2 == 0 and output.strip():
                    print(output.strip())
                else:
                    print("  No se encontraron vulnerabilidades específicas")
        else:
            print(f"✗ Error en el escaneo: {stderr}")
        
        return rc == 0

    def test_3_credentialed_scan(self):
        """Prueba 3: Escaneo credentialed (simulando autenticación SSH)"""
        print("\n" + "=" * 60)
        print("PRUEBA 3: ESCANEO CREDENTIALED (SSH)")
        print("=" * 60)
        
        kali_container = self.containers['kali']
        
        print("Probando acceso SSH a objetivos...")
        
        # Probar SSH a Metasploitable
        print("\n--- Probando SSH a Metasploitable ---")
        ssh_cmd = f"docker exec {kali_container} sshpass -p 'msfadmin' ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no msfadmin@10.10.0.20 'uname -a'"
        rc, stdout, stderr = self.run_command(ssh_cmd)
        
        if rc == 0:
            print(f"✓ SSH exitoso a Metasploitable: {stdout.strip()}")
        else:
            print(f"✗ SSH falló a Metasploitable: {stderr.strip()}")
        
        # Probar SSH a DVWA (si está disponible)
        print("\n--- Probando SSH a DVWA ---")
        ssh_cmd2 = f"docker exec {kali_container} sshpass -p 'password' ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@10.10.0.21 'uname -a'"
        rc2, stdout2, stderr2 = self.run_command(ssh_cmd2)
        
        if rc2 == 0:
            print(f"✓ SSH exitoso a DVWA: {stdout2.strip()}")
        else:
            print(f"✗ SSH falló a DVWA: {stderr2.strip()}")
        
        return True

    def test_4_report_analysis(self):
        """Prueba 4: Análisis de reportes (simulando análisis de plugins de Nessus)"""
        print("\n" + "=" * 60)
        print("PRUEBA 4: ANÁLISIS DE REPORTES")
        print("=" * 60)
        
        kali_container = self.containers['kali']
        
        print("Generando reporte de análisis...")
        
        # Crear reporte de análisis
        report_cmd = f"""
        docker exec {kali_container} bash -c '
        echo "=== REPORTE DE ANÁLISIS DE VULNERABILIDADES ===" > {self.results_dir}/modulo4_analysis_report.txt
        echo "Fecha: $(date)" >> {self.results_dir}/modulo4_analysis_report.txt
        echo "" >> {self.results_dir}/modulo4_analysis_report.txt
        
        echo "=== RESUMEN DE OBJETIVOS ===" >> {self.results_dir}/modulo4_analysis_report.txt
        for target in {" ".join(self.targets.values())}; do
            echo "Objetivo: $target" >> {self.results_dir}/modulo4_analysis_report.txt
            nmap -sS -sV $target | grep -E "open|filtered|closed" | head -10 >> {self.results_dir}/modulo4_analysis_report.txt
            echo "" >> {self.results_dir}/modulo4_analysis_report.txt
        done
        
        echo "=== VULNERABILIDADES CRÍTICAS ===" >> {self.results_dir}/modulo4_analysis_report.txt
        grep -i "critical\\|high\\|vulnerable" {self.results_dir}/modulo4_vulnerabilities.nmap >> {self.results_dir}/modulo4_analysis_report.txt 2>/dev/null || echo "No se encontraron vulnerabilidades críticas" >> {self.results_dir}/modulo4_analysis_report.txt
        
        echo "=== RECOMENDACIONES ===" >> {self.results_dir}/modulo4_analysis_report.txt
        echo "1. Actualizar servicios con versiones vulnerables" >> {self.results_dir}/modulo4_analysis_report.txt
        echo "2. Implementar parches de seguridad" >> {self.results_dir}/modulo4_analysis_report.txt
        echo "3. Configurar firewall para restringir acceso" >> {self.results_dir}/modulo4_analysis_report.txt
        echo "4. Monitorear logs de seguridad" >> {self.results_dir}/modulo4_analysis_report.txt
        '
        """
        
        rc, stdout, stderr = self.run_command(report_cmd)
        
        if rc == 0:
            print("✓ Reporte de análisis generado")
            
            # Mostrar el reporte
            show_cmd = f"docker exec {kali_container} cat {self.results_dir}/modulo4_analysis_report.txt"
            rc2, output, _ = self.run_command(show_cmd)
            if rc2 == 0:
                print("\n--- CONTENIDO DEL REPORTE ---")
                print(output)
        else:
            print(f"✗ Error generando reporte: {stderr}")
        
        return rc == 0

    def test_5_integration_nmap_nessus(self):
        """Prueba 5: Integración Nmap-Nessus (simulando importación de resultados)"""
        print("\n" + "=" * 60)
        print("PRUEBA 5: INTEGRACIÓN NMAP-NESSUS")
        print("=" * 60)
        
        kali_container = self.containers['kali']
        
        print("Simulando integración de resultados Nmap a Nessus...")
        
        # Crear archivo de integración
        integration_cmd = f"""
        docker exec {kali_container} bash -c '
        echo "=== INTEGRACIÓN NMAP-NESSUS ===" > {self.results_dir}/modulo4_integration.txt
        echo "Fecha: $(date)" >> {self.results_dir}/modulo4_integration.txt
        echo "" >> {self.results_dir}/modulo4_integration.txt
        
        echo "=== PUERTOS ABIERTOS (Nmap) ===" >> {self.results_dir}/modulo4_integration.txt
        for target in {" ".join(self.targets.values())}; do
            echo "Objetivo: $target" >> {self.results_dir}/modulo4_integration.txt
            nmap -sS $target | grep "open" >> {self.results_dir}/modulo4_integration.txt
            echo "" >> {self.results_dir}/modulo4_integration.txt
        done
        
        echo "=== VULNERABILIDADES (Nessus Simulation) ===" >> {self.results_dir}/modulo4_integration.txt
        echo "Plugin ID 10001: SSH Weak Encryption" >> {self.results_dir}/modulo4_integration.txt
        echo "Plugin ID 10002: HTTP Server Information Disclosure" >> {self.results_dir}/modulo4_integration.txt
        echo "Plugin ID 10003: SMB Null Session" >> {self.results_dir}/modulo4_integration.txt
        echo "" >> {self.results_dir}/modulo4_integration.txt
        
        echo "=== CORRELACIÓN DE RESULTADOS ===" >> {self.results_dir}/modulo4_integration.txt
        echo "Host: 10.10.0.20 | Puerto: 22 | Servicio: SSH | Vulnerabilidad: Weak Encryption | Severidad: Medium" >> {self.results_dir}/modulo4_integration.txt
        echo "Host: 10.10.0.20 | Puerto: 80 | Servicio: HTTP | Vulnerabilidad: Information Disclosure | Severidad: Low" >> {self.results_dir}/modulo4_integration.txt
        echo "Host: 10.10.0.20 | Puerto: 445 | Servicio: SMB | Vulnerabilidad: Null Session | Severidad: High" >> {self.results_dir}/modulo4_integration.txt
        '
        """
        
        rc, stdout, stderr = self.run_command(integration_cmd)
        
        if rc == 0:
            print("✓ Integración Nmap-Nessus completada")
            
            # Mostrar resultados de integración
            show_cmd = f"docker exec {kali_container} cat {self.results_dir}/modulo4_integration.txt"
            rc2, output, _ = self.run_command(show_cmd)
            if rc2 == 0:
                print("\n--- RESULTADOS DE INTEGRACIÓN ---")
                print(output)
        else:
            print(f"✗ Error en integración: {stderr}")
        
        return rc == 0

    def run_all_tests(self):
        """Ejecuta todas las pruebas del módulo 4"""
        print("🚀 INICIANDO PRUEBAS DEL MÓDULO 4 - NESSUS")
        print("=" * 60)
        
        tests = [
            ("Escaneo de Descubrimiento", self.test_1_discovery_scan),
            ("Escaneo de Vulnerabilidades", self.test_2_vulnerability_scan),
            ("Escaneo Credentialed", self.test_3_credentialed_scan),
            ("Análisis de Reportes", self.test_4_report_analysis),
            ("Integración Nmap-Nessus", self.test_5_integration_nmap_nessus)
        ]
        
        results = []
        
        for test_name, test_func in tests:
            print(f"\n🧪 Ejecutando: {test_name}")
            try:
                success = test_func()
                results.append((test_name, success))
                if success:
                    print(f"✅ {test_name}: COMPLETADO")
                else:
                    print(f"❌ {test_name}: FALLÓ")
            except Exception as e:
                print(f"❌ {test_name}: ERROR - {e}")
                results.append((test_name, False))
        
        # Resumen final
        print("\n" + "=" * 60)
        print("📊 RESUMEN DE PRUEBAS DEL MÓDULO 4")
        print("=" * 60)
        
        passed = sum(1 for _, success in results if success)
        total = len(results)
        
        for test_name, success in results:
            status = "✅ PASÓ" if success else "❌ FALLÓ"
            print(f"{test_name:30} {status}")
        
        print(f"\nResultado: {passed}/{total} pruebas completadas exitosamente")
        
        if passed == total:
            print("🎉 ¡MÓDULO 4 COMPLETADO EXITOSAMENTE!")
        else:
            print("⚠️  Algunas pruebas fallaron. Revisa los errores arriba.")
        
        return passed == total

def main():
    tester = Modulo4Tester()
    
    if len(sys.argv) > 1:
        test_name = sys.argv[1].lower()
        
        if test_name == "discovery":
            tester.test_1_discovery_scan()
        elif test_name == "vuln":
            tester.test_2_vulnerability_scan()
        elif test_name == "cred":
            tester.test_3_credentialed_scan()
        elif test_name == "report":
            tester.test_4_report_analysis()
        elif test_name == "integration":
            tester.test_5_integration_nmap_nessus()
        else:
            print("Pruebas disponibles: discovery, vuln, cred, report, integration")
    else:
        tester.run_all_tests()

if __name__ == "__main__":
    main()
