#!/bin/sh
nova list | grep {{ host }} | awk -F '|' '{print  }'  | xargs nova delete
cinder list | grep {{ host }}  | awk -F '|' '{print  }'  | xargs cinder delete
for i in pool listener loadbalancer;do neutron lbaas-loadbalancer-list | grep lb | awk -F '|' '{print }' | xargs neutron lbaas-loadbalancer-delete; done
