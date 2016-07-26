# ansible-playbook
1. ansible playbook for docker swarm test
this playbook create simple docker swarm service and network automatically.

file: 
- docker-swarm/docker-swarm.yml
- docker-swarm/clear-docker-swarm.yml

hosts:
- rhel7: ansible server
- rhel71: docker master
- rhel72: doerer worker
