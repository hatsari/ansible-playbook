# ansible playbooks collection
1. docker swarm test
  playbook: docker-swarm.yml
    tasks:
      initialize docker swarm
      join client
      view docker swarm status
      print docker swarm status
      create docker overlay network
      view docker net status
      print docker net status
      create service

2. os-basic operation
  playbook: os-basic.yml
    tasks:
      selinux disable
      register hostname to /etc/host file 
      copy repo file
      add repo server
      yum update all

3. gluster with ganesha
  playbook: gluster-ganesha.yml
    tasks:
      install ganesha packages
      copy ganesha-ha.conf
      disable gluster-nfs
      start pacemaker
      set password of hacluster user
      check cluster auth
      enable nfs-ganesha
      verify cluster status 
      export subdirectory entire (before that, you should make subdirectory on vol)
      restart nfs-ganesha service 
      verify nfs exports on rhgs1
      install nfs client on client systems
      mount vol/subdir from client
