#!/usr/bin/env python3
"""
Parser de salida XML de Nmap para el laboratorio Docker
Adaptado para funcionar en contenedores
"""

import xml.etree.ElementTree as ET
import sys
import csv
import json
import os
from datetime import datetime

def parse_nmap_xml(input_xml, out_csv=None, out_json=None):
    """
    Parsea archivo XML de Nmap y genera salidas en CSV/JSON
    """
    try:
        tree = ET.parse(input_xml)
        root = tree.getroot()
    except ET.ParseError as e:
        print(f"Error al parsear XML: {e}")
        return
    except FileNotFoundError:
        print(f"Archivo no encontrado: {input_xml}")
        return

    results = []
    scan_info = {}
    
    # Extraer información del escaneo
    if root.find('scaninfo') is not None:
        scan_info = {
            'protocol': root.find('scaninfo').get('protocol', 'unknown'),
            'numservices': root.find('scaninfo').get('numservices', 'unknown')
        }
    
    # Procesar cada host
    for host in root.findall('host'):
        addr_elem = host.find('address')
        addr = addr_elem.get('addr') if addr_elem is not None else 'unknown'
        
        # Información del host
        hostname = 'unknown'
        if host.find('hostnames') is not None:
            hostname_elem = host.find('hostnames').find('hostname')
            if hostname_elem is not None:
                hostname = hostname_elem.get('name', 'unknown')
        
        # Estado del host
        host_status = 'unknown'
        if host.find('status') is not None:
            host_status = host.find('status').get('state', 'unknown')
        
        # Procesar puertos
        ports = host.find('ports')
        if ports is None:
            continue
            
        for port in ports.findall('port'):
            portid = port.get('portid')
            proto = port.get('protocol')
            state_elem = port.find('state')
            state = state_elem.get('state') if state_elem is not None else 'unknown'
            
            # Información del servicio
            svc = port.find('service')
            service = svc.get('name') if svc is not None and 'name' in svc.attrib else ''
            version = svc.get('version') if svc is not None and 'version' in svc.attrib else ''
            product = svc.get('product') if svc is not None and 'product' in svc.attrib else ''
            extrainfo = svc.get('extrainfo') if svc is not None and 'extrainfo' in svc.attrib else ''
            
            # Información de scripts NSE
            scripts_info = []
            if port.find('script') is not None:
                for script in port.findall('script'):
                    script_info = {
                        'id': script.get('id', ''),
                        'output': script.text.strip() if script.text else ''
                    }
                    scripts_info.append(script_info)
            
            result = {
                'timestamp': datetime.now().isoformat(),
                'host': addr,
                'hostname': hostname,
                'host_status': host_status,
                'protocol': proto,
                'port': portid,
                'state': state,
                'service': service,
                'version': version,
                'product': product,
                'extrainfo': extrainfo,
                'scripts': scripts_info,
                'scan_info': scan_info
            }
            results.append(result)

    # Generar salidas
    if out_csv:
        write_csv(results, out_csv)
    
    if out_json:
        write_json(results, out_json)
    
    # Mostrar resumen
    print_summary(results)
    
    return results

def write_csv(results, filename):
    """Escribe resultados en formato CSV"""
    if not results:
        print("No hay resultados para escribir en CSV")
        return
    
    # Flatten scripts para CSV
    csv_results = []
    for result in results:
        base_result = {k: v for k, v in result.items() if k != 'scripts'}
        if result['scripts']:
            for script in result['scripts']:
                csv_result = base_result.copy()
                csv_result['script_id'] = script['id']
                csv_result['script_output'] = script['output'][:100]  # Truncar para CSV
                csv_results.append(csv_result)
        else:
            csv_results.append(base_result)
    
    keys = list(csv_results[0].keys())
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=keys)
        writer.writeheader()
        writer.writerows(csv_results)
    print(f"✓ Resultados guardados en CSV: {filename}")

def write_json(results, filename):
    """Escribe resultados en formato JSON"""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    print(f"✓ Resultados guardados en JSON: {filename}")

def print_summary(results):
    """Imprime resumen de resultados"""
    if not results:
        print("No se encontraron resultados")
        return
    
    hosts = set(r['host'] for r in results)
    open_ports = [r for r in results if r['state'] == 'open']
    services = set(r['service'] for r in open_ports if r['service'])
    
    print("\n=== RESUMEN DEL ESCANEO ===")
    print(f"Hosts escaneados: {len(hosts)}")
    print(f"Puertos abiertos encontrados: {len(open_ports)}")
    print(f"Servicios únicos: {len(services)}")
    
    print("\n=== HOSTS ENCONTRADOS ===")
    for host in sorted(hosts):
        host_ports = [r for r in open_ports if r['host'] == host]
        print(f"{host}: {len(host_ports)} puertos abiertos")
        for port_info in host_ports:
            service_info = f"{port_info['service']}" if port_info['service'] else "unknown"
            version_info = f" ({port_info['version']})" if port_info['version'] else ""
            print(f"  {port_info['protocol']}/{port_info['port']}: {service_info}{version_info}")

def main():
    if len(sys.argv) < 2:
        print("Uso: parse_nmap_xml.py scan.xml [--csv out.csv] [--json out.json]")
        print("Ejemplo: python3 parse_nmap_xml.py resultados/scan.xml --csv reports/summary.csv --json reports/summary.json")
        sys.exit(1)

    input_xml = sys.argv[1]
    out_csv = None
    out_json = None
    
    if '--csv' in sys.argv:
        csv_index = sys.argv.index('--csv')
        if csv_index + 1 < len(sys.argv):
            out_csv = sys.argv[csv_index + 1]
    
    if '--json' in sys.argv:
        json_index = sys.argv.index('--json')
        if json_index + 1 < len(sys.argv):
            out_json = sys.argv[json_index + 1]
    
    # Crear directorios si no existen
    if out_csv and not os.path.exists(os.path.dirname(out_csv)):
        os.makedirs(os.path.dirname(out_csv), exist_ok=True)
    if out_json and not os.path.exists(os.path.dirname(out_json)):
        os.makedirs(os.path.dirname(out_json), exist_ok=True)
    
    parse_nmap_xml(input_xml, out_csv, out_json)

if __name__ == "__main__":
    main()
