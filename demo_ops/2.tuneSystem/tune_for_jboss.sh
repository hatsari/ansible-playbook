#! /bin/sh
#
echo net.core.rmem_default=262144 >> /etc/sysctl.conf
echo net.core.wmem_default=262144 >> /etc/sysctl.conf
echo net.core.rmem_max=262144 >> /etc/sysctl.conf
echo net.core.wmem_max=262144 >> /etc/sysctl.conf

echo vm.min_free_kbytes=1024 >> /etc/sysctl.conf
echo vm.swappiness=10 >> /etc/sysctl.conf
echo "vm.nr_hugepages=512" >> /etc/sysctl.conf
echo "fs.file-max=64000"  >> /etc/sysctl.conf

ulimit  -n 8192

echo "1024 65000" > /proc/sys/net/ipv4/ip_local_port_range


sysctl -p
sysctl -a
