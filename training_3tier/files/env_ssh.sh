#! /bin/sh
#
# env_ssh.sh
# Copyright (C) 2017 ykim <ykim@KimYongKis-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.
#

export OSPGUID=bcff

wget http://www.opentlc.com/download/ansible_bootcamp/openstack_keys/openstack.pem -O ~/.ssh/openstack.pem
chmod 400 ~/.ssh/openstack.pem


cat << EOF >> ssh.cfg
Host workstation-${OSPGUID}.rhpds.opentlc.com
 Hostname workstation-${OSPGUID}.rhpds.opentlc.com
 IdentityFile ~/.ssh/openstack.pem
 ForwardAgent yes
 User cloud-user
 StrictHostKeyChecking no
 PasswordAuthentication no

Host 10.10.10.*
 User cloud-user
 IdentityFile ~/.ssh/openstack.pem
 ProxyCommand ssh cloud-user@workstation-${OSPGUID}.rhpds.opentlc.com -W %h:%p -vvv
 StrictHostKeyChecking no
EOF


cat << EOF > osp_jumpbox_inventory
[jumpbox]
workstation-${OSPGUID}.rhpds.opentlc.com ansible_ssh_user=cloud-user ansible_ssh_private_key_file=~/.ssh/openstack.pem
EOF

ansible -i osp_jumpbox_inventory all -m ping

ansible -i osp_jumpbox_inventory jumpbox -m os_user_facts -a cloud=ospcloud -v
