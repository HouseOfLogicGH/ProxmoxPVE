# Terraform / OpenTofu with Cloud Init on Proxmox Readme

This folder has the code used to clone Cloud Init VMs using Terraform / OpenTofu on Proxmox.
You wil find the cloud init image setup commands in cloudinitsetuporacular.sh

Note that in the original config, this option did not work with terraform
qm set 9000 --boot order=scsi0

It had to be replaced with:
qm set 9000 --boot c --bootdisk scsi0

## Video Demonstration
[House of Logic demo video](https://youtu.be/HbBblJOZs-c)


## Reference Material

[Proxmox Cloud Init Wiki Page](https://pve.proxmox.com/wiki/Cloud-Init_Support)


[Telmate Terraform Cloud Init Example](https://github.com/Telmate/terraform-provider-proxmox/blob/master/examples/cloudinit_example.tf)



