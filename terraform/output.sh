#!/bin/bash

# Получаем IP-адреса
WEBSERVER_1_INTERNAL_IP=$(terraform output -json internal_ip_address_webserver-1 | jq -r '.')
WEBSERVER_2_INTERNAL_IP=$(terraform output -json internal_ip_address_webserver-2 | jq -r '.')
GRAFANA_INTERNAL_IP=$(terraform output -json internal_ip_address_grafana-server | jq -r '.')
KIBANA_INTERNAL_IP=$(terraform output -json internal_ip_address_kibana-server | jq -r '.')
ELASTICSEARCH_INTERNAL_IP=$(terraform output -json internal_ip_address_elasticsearch-server | jq -r '.')
PROMETHEUS_INTERNAL_IP=$(terraform output -json internal_ip_address_prometheus-server | jq -r '.')
BASTION_EXTERNAL_IP=$(terraform output -json external_ip_address_bastion | jq -r '.')

# Формируем inventory
cat <<EOF > ../Ansible/inventory.ini
[all:vars]
ansible_user=super_user
ansible_ssh_private_key_file=/home/admin/.ssh/id_rsa

[bastion]
bastion ansible_host=$BASTION_EXTERNAL_IP

[webservers]
webserver-1 ansible_host=$WEBSERVER_1_INTERNAL_IP ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -q super_user@BASTION_EXTERNAL_IP"'
webserver-2 ansible_host=$WEBSERVER_2_INTERNAL_IP ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -q super_user@BASTION_EXTERNAL_IP"'

[elk]
elasticsearch-server ansible_host=$ELASTICSEARCH_INTERNAL_IP ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -q super_user@BASTION_EXTERNAL_IP"'
kibana-server ansible_host=$KIBANA_INTERNAL_IP ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -q super_user@BASTION_EXTERNAL_IP"'

[monitoring]
prometheus-server ansible_host=$PROMETHEUS_INTERNAL_IP ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -q super_user@BASTION_EXTERNAL_IP"'
grafana-server ansible_host=$GRAFANA_INTERNAL_IP ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -q super_user@BASTION_EXTERNAL_IP"'

EOF