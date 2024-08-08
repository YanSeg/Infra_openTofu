#!/usr/bin/env python3

import yaml
import subprocess
import re


output_file = "ansible/inventory.yml"

def get_ip_address(name):
    try:
        # Run virsh command and capture output
        result = subprocess.run(['virsh', 'domifaddr', name], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode == 0:
            # Use regex to find IP address
            ip_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', result.stdout)
            if ip_match:
                return ip_match.group(0)
        # Handle error or no IP found
        return None
    except subprocess.CalledProcessError:
        return None

def update_inventory_file(host_name, ip_address):
    try:
        with open(output_file, 'r') as f:
            inventory_data = yaml.safe_load(f)
        
        if host_name in inventory_data['all']['hosts']:
            inventory_data['all']['hosts'][host_name]['ansible_host'] = ip_address
        else:
            inventory_data['all']['hosts'][host_name] = {
                'ansible_host': ip_address,
                'ansible_user': 'admin',
                'ansible_ssh_common_args': '-o StrictHostKeyChecking=no'
            }
        
        with open(output_file, 'w') as f:
            yaml.dump(inventory_data, f)
    except FileNotFoundError:
        print(f"Error: {output_file} not found.")
    except yaml.YAMLError as e:
        print(f"Error while parsing YAML: {e}")

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 2:
        print("Usage: python script.py <domain_name>")
        sys.exit(1)
    
    name = sys.argv[1]
    ip = get_ip_address(name)
    
    if ip:
        update_inventory_file(name, ip)
    else:
        print(f"Error: Unable to find IP address for {name}")
