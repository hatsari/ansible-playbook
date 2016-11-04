# ansible-playbook for docker swarm test
1. ansible playbook for docker swarm test
This playbook create simple docker swarm service and network automatically.
Docker swarm would be embedded into it after v1.12. (currently not yet released, 26 July 2016
so download docker 1.12 rc: https://github.com/docker/docker/releases
# install: "curl -fsSL https://test.docker.com/ | sh"

in purpose of knowing docker command, I just use shell module.

file: 
- docker-swarm/docker-swarm.yml
  - initialize docker swarm 
  - join swarm client
  - view docker node
  - create overlay network
  - create httpd service

- docker-swarm/clear-docker-swarm.yml
  - delete docker service
  - delete docker network
  - leave docker swarm

hosts:
- rhel7: ansible server
- rhel71: docker master
- rhel72: doerer worker
