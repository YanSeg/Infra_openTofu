resource "libvirt_volume" "cms_server_ubuntu-qcow2" {
  name = "cms_server_ubuntu-qcow2"
  source = "/home/user/Desktop/TRASH/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data_ubuntu" {
  template = file("${path.module}/user-data.yml")
}

resource "libvirt_cloudinit_disk" "init_ubuntu" {
  name           = "init_ubuntu.iso"
  user_data      = data.template_file.user_data_ubuntu.rendered
}

resource "libvirt_domain" "cms_server_ubuntu" {
  name   = "cms_server_ubuntu"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.init_ubuntu.id
  
  cpu  {
    mode = "host-passthrough"
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.cms_server_ubuntu-qcow2.id
  }


  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "none"
    }


  
  provisioner "local-exec" {
   command = <<EOT
    sleep 30
    python3 modify_inventory.py ${self.name}
    EOT
  }

}



