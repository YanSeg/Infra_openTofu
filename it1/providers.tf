terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}