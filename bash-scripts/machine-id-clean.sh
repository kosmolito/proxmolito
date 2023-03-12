#!/bin/bash
echo "Cleaning machine-id"
sudo cloud-init clean

echo "Removing cloud-init files"
sudo rm -rf /var/lib/cloud/instances

echo "Removing machine-id in /etc and /var/lib/dbus"
sudo truncate -s 0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id

echo "Creating symlink for machine-id"
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

echo "Machine is clean. Powering off the VM!"

sudo poweroff