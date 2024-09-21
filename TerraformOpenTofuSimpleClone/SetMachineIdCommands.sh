#!/bin/bash
# run as sudo or this won't work
echo -n >/etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id