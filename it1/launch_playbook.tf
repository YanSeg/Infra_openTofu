resource "null_resource" "ansible" {
    provisioner "local-exec" {
        command = "ansible-playbook -i ansible/inventory.yml ansible/deploy_cms.yml"
      
    }
    depends_on = [ libvirt_domain.cms_server_rocky , libvirt_domain.cms_server_ubuntu ]
}

resource "null_resource" "ansible-zabbix" {
    
    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        command = "ansible-playbook -i ansible/inventory.yml ansible/deploy_zabbix_agent.yml -e zabbix_server_ip=${[for interface in docker_container.zabbix-server-mysql.network_data: interface.ip_address if interface.network_name == "osef"][0]}"
      
    }

    depends_on = [
        docker_container.mysql,
        docker_container.zabbix-server-mysql,
        docker_container.zabbix-web-apache-mysql,
        null_resource.ansible
    ]
}




resource "null_resource" "ansible_service" {
    provisioner "local-exec" {
        command = "ansible-playbook -i ansible/inventory.yml ansible/deploy_service.yml"
    }
    depends_on = [ null_resource.ansible-zabbix  ]
}


resource "null_resource" "host_scripts" {
    provisioner "local-exec" {
        command = "python3 create_zabbix_hosts_items.py"
    }
    depends_on = [ null_resource.ansible_service ]
}