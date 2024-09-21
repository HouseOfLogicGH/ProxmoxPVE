# Provider configuration (provider.tf)
terraform {
  required_providers {
    proxmox = {
      source  = "TheGameProfi/proxmox"
     # source = "telmate/proxmox"
      version = "2.9.15"
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

resource "proxmox_vm_qemu" "test-clone" {
  count = 2 # number of VMs to create
  name = "VM-Clone-Terraform-${count.index + 1}"
  desc        = "Clone demo"
  target_node = "proxmoxnodename"
  
  ### Clone VM operation
  clone = "ubuntu2404template"
  # note that cores, sockets and memory settings are not copied from the source VM template
  cores = 1
  sockets = 1
  memory = 2048 

  # Activate QEMU agent for this VM
  agent = 1
}
