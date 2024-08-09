resource "docker_image" "zabbix-server-mysql" {
  name = "zabbix/zabbix-server-mysql:ubuntu-6.4-latest"

}


resource "docker_image" "zabbix-web-apache-mysql"{
  name = "zabbix/zabbix-web-apache-mysql:ubuntu-6.4-latest"
  }


resource "docker_image" "mysql" {
  name = "mysql:8.0.30"
}


resource "docker_network" "custom_network" {
  name = "custom_network"
  driver = "bridge"
  ipam_config {
    subnet = "192.168.10.0/24"
  }
}

## 

resource "docker_network" "libvirt_network" {
  name = "osef"
  driver = "macvlan"
  ipam_config{
    subnet = "192.168.122.0/24"
  }
  options = {
    parent = "virbr0"
  }
}


resource "docker_container" "mysql" {
  name  = "mysql_container"
  image = docker_image.mysql.name

  ports {
    internal = 3306
    external = 3306
  }

  networks_advanced {
    name = docker_network.custom_network.name
    ipv4_address = "192.168.10.10"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=root_password",
    "MYSQL_DATABASE=zabbix",
    "MYSQL_USER=zabbix",
    "MYSQL_PASSWORD=zabbix"
  ]
}



resource "docker_container" "zabbix-server-mysql" {
  name  = "zabbix-server-mysql"
  image = docker_image.zabbix-server-mysql.name

  ports {
    internal = 10051
    external = 10051
  }

  ports {
    internal = 10050
    external = 10050
  }

  networks_advanced {
    name = docker_network.custom_network.name
    ipv4_address = "192.168.10.20"
  }

  networks_advanced {
    name = docker_network.libvirt_network.name
  }


  env = [
    "DB_SERVER_HOST=192.168.10.10",
    "MYSQL_DATABASE=zabbix",
    "MYSQL_USER=zabbix",
    "MYSQL_PASSWORD=zabbix",
    "MYSQL_ROOT_PASSWORD=root_password"
  ]
  depends_on = [ docker_container.mysql ]
}



resource "docker_container""zabbix-web-apache-mysql"{
  name  = "zabbix-web-apache-mysql"
  image = docker_image.zabbix-web-apache-mysql.name

  networks_advanced {
    name = docker_network.custom_network.name
    ipv4_address = "192.168.10.21"
  }

  ports {
    internal = 8080
    external = 8080
  }
    env = [
    "DB_SERVER_HOST=192.168.10.10",
    "MYSQL_DATABASE=zabbix",
    "MYSQL_USER=zabbix",
    "MYSQL_PASSWORD=zabbix",
    "ZBX_SERVER_HOST=192.168.10.20"
  ]

  depends_on = [ 
    docker_container.mysql,
    docker_container.zabbix-server-mysql
   ]
}
