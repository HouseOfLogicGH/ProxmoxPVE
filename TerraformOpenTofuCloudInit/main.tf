# Provider configuration (provider.tf)
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://proxmoxhostnameorip:8006/api2/json"
#  username and password options for security
#  pm_user    = "root@pam"
#  pm_password = "YourPasswordHere"

  # insecure unless using signed certificates
  pm_tls_insecure = true
  
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "root@pam!YourTokenId"

  # this is the full secret wrapped in quotes:
  pm_api_token_secret = "token-secret-here"

}

resource "proxmox_vm_qemu" "cloudinit-test" {
    name = "terraform-test-vm"
    desc = "A test for using terraform and cloudinit"

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "proxmoxnodename"

    # The destination resource pool for the new VM
#    pool = "pool0"

    # The template name to clone this vm from
    clone = "VM 9000"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 2048
    scsihw = "virtio-scsi-pci"

    # Setup the disk
    disks {
        ide {
            ide2 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi0 {
                disk {
                    size            = 32
                    cache           = "writeback"
                    storage         = "local-lvm"
                    #storage_type    = "rbd"
                    #iothread        = true
                    #discard         = true
                    replicate       = true
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
        #tag = 256
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi0"
    # Keep in mind to use the CIDR notation for the ip.
    #ipconfig0 = "ip=192.168.10.20/24,gw=192.168.10.1"
    ipconfig0 = "ip=dhcp"
    #sshkeys = <<EOF
    #ssh-rsa 9182739187293817293817293871== user@pc
    #EOF
    serial {
      id   = 0
      type = "socket"
    }
    
    ciuser = "youusername"
    cipassword = "yourpassword"

}
