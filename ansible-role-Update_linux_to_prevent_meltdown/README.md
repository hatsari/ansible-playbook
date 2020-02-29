Update_packages_to_prevent_meltdown
=========

This role will update packages related to meltdown/spectre to prevent from its damages.

After appying it, you should **REBOOT** system by yourself.

tested on ansible-2.4

ChangeLogs:
  - 01.09.2017: check the rhel version and apply proper kerenl version 
  - 01.08.2017: first released, only support rhel7

Requirements
------------

- package repository should be prepared already. 
- this role don't provide the repository configuration.
- however, you can use "centos7.repo" if you wish.

Role Variables
--------------

Only one variable is used here to compare the kernel version.
Variable name is **new_kernel**. It is fixed to *3.10.0-693*.

Dependencies
------------

This role only works for Red Hat like distros.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: hatsari.Update_packages_to_prevent_meltdown, new_kernel: 3.10.0-693 }

Sample Playbook
---------------
```
---
- name: update kernel, kernel-rt, libvirt, qumu-kvm, python and dracut to prevent meltdown
  hosts: servers
  vars:
    - new_kernel: 3.10.0-693
  become: true
  tasks:
    - name: print current kernel version
      debug:
        msg: "Current Kernel version is {{ ansible_kernel }} and it should be more than {{ new_kernel }}"

    - name: update packages related to meltdown
      command: yum update -y "{{ item }}"
      with_items:
        - kernel
        - kernel-rt
        - libvirt
        - qumu-kvm
        - python
      when: ansible_kernel | version_compare(new_kernel, '<')
```

License
-------

BSD

Author Information
------------------
HatSAri
Alex, YONGKI KIM
https://github.com/hatsari
