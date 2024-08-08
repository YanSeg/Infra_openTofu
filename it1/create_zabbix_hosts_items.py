import requests
import json
import yaml
import time

ZABBIX_API_URL = "http://localhost:8080/api_jsonrpc.php"

headers = {
    'Content-Type': 'application/json-rpc',
}

def get_auth_token(username,password):
    payload = json.dumps({
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
            "username": username,
            "password": password
        },
        "id": 1,
        "auth": None
    })

    response = requests.post(ZABBIX_API_URL, headers=headers, data=payload)
    return response.json()['result']

def get_templateid_by_name(auth_token, template_name):
    payload = json.dumps({
        "jsonrpc": "2.0",
        "method": "template.get",
        "params": {
            "filter": {
                "host": [template_name]
            }
        },
        "auth": auth_token,
        "id": 1
    })

    response = requests.post(ZABBIX_API_URL, headers=headers, data=payload)
    template_id = response.json()['result'][0]['templateid']
    return template_id

def get_hostgroup_id_by_name(auth_token,group_name):
    payload = json.dumps({
        "jsonrpc": "2.0",
        "method": "hostgroup.get",
        "params": {
            "filter": {
                "name": [group_name]
            }
        },
        "auth": auth_token,
        "id": 1
    })

    response = requests.post(ZABBIX_API_URL, headers=headers, data=payload)
    return response.json()['result'][0]['groupid']

def create_host(auth_token, host_name, ip_address, group_id, template_id):
    headers = {'Content-Type': 'application/json-rpc'}
    data = {
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": host_name,
            "interfaces": [
                {
                    "type": 1,
                    "main": 1,
                    "useip": 1,
                    "ip": ip_address,
                    "dns": "",
                    "port": "10050"
                }
            ],
            "groups": [
                {
                    "groupid": group_id
                }
            ],
            "templates": [
                {
                    "templateid": template_id
                }
            ]
        },
        "auth": auth_token,
        "id": 1
    }

    response = requests.post(ZABBIX_API_URL, headers=headers, data=json.dumps(data))
    return response.json()

def get_ip_addresses(ansible_inventory):
    with open(ansible_inventory, 'r') as file:
        inventory = yaml.safe_load(file)
    
    hosts = inventory.get('all', {}).get('hosts', {})
    ip_addresses = {host: details.get('ansible_host') for host, details in hosts.items()}
    
    return ip_addresses

def create_item(auth_token,item_name, item_key, host_id, interface_id, item_type=0, value_type=3, delay='300'):
    item_params = {
        "name": item_name,
        "key_": item_key,
        "hostid": host_id,
        "type": item_type,
        "value_type": value_type,
        "interfaceid": interface_id,
        "delay": delay,
    }



    # JSON-RPC request payload for item creation
    payload = {
        "jsonrpc": "2.0",
        "method": "item.create",
        "params": item_params,
        "auth": auth_token,
        "id": 1
    }

    try:
        # Make the item creation request
        response = requests.post(ZABBIX_API_URL, headers=headers, data=json.dumps(payload))
        response.raise_for_status()       


        return response.json()

    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

while True:
    try:
        auth_token = get_auth_token("Admin","zabbix")
        break
    except KeyError:
        print("trying again")
        time.sleep(1)
        
def get_interface_id(auth_token, hostid, interface_type=1):
    payload = {
        "jsonrpc": "2.0",
        "method": "hostinterface.get",
        "params": {
            "hostids": hostid
        },
        "auth": auth_token,
        "id": 1
    }
    response = requests.post(ZABBIX_API_URL, headers=headers, data=json.dumps(payload))
    response_data = response.json()
    if 'error' in response_data:
        print(f"Error: {response_data['error']['message']}")
        return None

    interfaces = response_data['result']
    
    for interface in interfaces:
        if int(interface['type']) == interface_type:
            return interface['interfaceid']
    
    return None    
    
template_name = "Linux by Zabbix agent"
group_name = "Linux servers"
ansible_inventory = "ansible/inventory.yml"


template_id = get_templateid_by_name(auth_token,template_name)
group_id = get_hostgroup_id_by_name(auth_token,group_name)

ip_addresses = get_ip_addresses(ansible_inventory)



host_ids = [create_host(auth_token, host_name, ip_address, group_id, template_id)['result']['hostids'][0] for host_name, ip_address in ip_addresses.items()]

for host_id in host_ids:
    item_name = "Replication status"
    item_key = "custom.logfile.read"
    interface_id = get_interface_id(auth_token, host_id)
    result = create_item(auth_token,item_name, item_key, host_id, interface_id,value_type=4)

print(result)