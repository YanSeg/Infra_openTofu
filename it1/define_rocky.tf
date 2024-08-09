resource "libvirt_volume" "cms_server_rocky-qcow2" {
  name = "cms_server_rocky-qcow2"
  source = "/home/user/Desktop/TRASH/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  format = "qcow2"
}

data "template_file" "user_data_rocky" {
  template = file("${path.module}/user-data_copy.yml")
}

resource "libvirt_cloudinit_disk" "init_rhel" {
  name           = "init_rhel.iso"
  user_data      = data.template_file.user_data_rocky.rendered
}


resource "libvirt_domain" "cms_server_rocky" {
  name   = "cms_server_rocky"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.init_rhel.id

  cpu  {
    mode = "host-passthrough"
  }
  
  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.cms_server_rocky-qcow2.id
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



