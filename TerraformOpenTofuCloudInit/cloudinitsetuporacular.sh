#!/bin/bash
# run these commands on the proxmox host as root

# download the image
wget https://cloud-images.ubuntu.com/oracular/current/oracular-server-cloudimg-amd64.img

# download libguestfs for the virt-customise tool 
apt update -y && apt install libguestfs-tools -y

# configure the image with qemu-guest-agent using virt customise
virt-customize -a oracular-server-cloudimg-amd64.img --install qemu-guest-agent

# create a new VM with VirtIO SCSI controller
qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci

# import the downloaded disk to the local-lvm storage, attaching it as a SCSI drive
# note that import path must be a full path, not relative
qm set 9000 --scsi0 local-lvm:0,import-from=/root/oracular-server-cloudimg-amd64.img

# set boot and display options
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --serial0 socket --vga serial0

# very important - had to be updated in the image
qm set 9000 --boot c --bootdisk scsi0

# turn the VM into a template
qm template 9000
