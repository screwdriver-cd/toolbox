#!/bin/bash -e

echo Downloading dependencies, qemu-hyper, hyper-container and hyperstart
cd /tmp
sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y autoconf automake pkg-config libdevmapper-dev libsqlite3-dev libvirt-dev libvirt-bin -qq
wget https://hypercontainer-download.s3-us-west-1.amazonaws.com/qemu-hyper/qemu-hyper_2.4.1-1_amd64.deb && sudo dpkg -i --force-all qemu-hyper_2.4.1-1_amd64.deb
wget https://hypercontainer-download.s3-us-west-1.amazonaws.com/0.8/debian/hypercontainer_0.8.1-1_amd64.deb && sudo dpkg -i --force-all hypercontainer_0.8.1-1_amd64.deb
wget https://hypercontainer-download.s3-us-west-1.amazonaws.com/0.8/debian/hyperstart_0.8.1-1_amd64.deb && sudo dpkg -i --force-all hyperstart_0.8.1-1_amd64.deb

echo Overriding the hyper config file
cat > /etc/hyper/config << 'EOF'
# Boot kernel
Kernel=/var/lib/hyper/kernel
# Boot initrd
Initrd=/var/lib/hyper/hyper-initrd.img
# Storage driver for hyperd, valid value includes devicemapper, overlay, and aufs
StorageDriver=devicemapper
# Hypervisor to run containers and pods, valid values are: libvirt, qemu, kvm, xen
Hypervisor=qemu
EOF

echo Start the hyperd service
systemctl daemon-reload; systemctl enable hyperd; systemctl start hyperd


