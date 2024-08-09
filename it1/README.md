##################################################################################

##################################################################################


# 1 _ Installation

```
sudo apt-get update
sudo apt install qemu-kvm libvirt-bin
sudo adduser $USER libvirtd
sudo apt install virtinst
sudo apt install -y libguestfs-tools genisoimage
sudo apt install wget curl unzip vim
sudo apt-get install jq
sudo apt install -y libguestfs-tools genisoimage
```

 Installation d'Ansible 
```
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get install ansible
```

- Installer opentofu
```
snap install --classic opentofu
tofu --version
```


- Installer dcoker 



- Vérifier que libvird is running and enabled 
```
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```


- Enable vhost-net kernel module on Ubuntu/Debian.
```
sudo modprobe vhost_net
echo vhost_net | sudo tee -a /etc/modules
```

- **Important** de rajouer security_driver = "none" dans /etc/libvirt/qemu.conf



** doc virsh : https://guide.ubuntu-fr.org/server/libvirt.html



# 2 _ Penser à mettre ces clefs publique :

- Dans user-data.yml && user-dtat_copy.yml


# 3 _ Création d'un pool default pour virsh s'il n'existe pas 

** Créer ou vérifier qu'un pool par defaut existe : https://gist.github.com/plembo/13ce29c9279807adfd9bd6b959f43fac **

- Créer un dossier 
```
sudo mkdir -p /data1/libvirt/images
```
```
virsh pool-define-as default dir --target "/data1/libvirt/images"
virsh pool-build default
virsh pool-start default
virsh pool-autostart default
```
- Checker les infos 
```
virsh pool-info default
```


#  4 _ Télécharger les iso et changer la taille des images 

- focal-server-cloudimg-amd64.img
- Rocky-9-GenericCloud-Base.latest.x86_64.qcow2

```
quemu info focal-server-cloudimg-amd64.img
```
```
qemu-img resize focal-server-cloudimg-amd64.img +18G 
```

#  5 _ Changer le chemn des iso dans  define_ubuntu.tf & definie_rocky.tf



# 6 _ Se connecter à la base de données

mysql -p (puis rentrer le passwd) mdp dans var du role ansible install_mysql

Puis show SLAVE status\G; (ou matser en focntion)



