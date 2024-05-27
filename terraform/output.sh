#!/bin/bash

# Получаем IP-адреса
WEBSERVER_1_INTERNAL_IP=$(terraform output -json internal_ip_address_webserver-1 | jq -r '.')
WEBSERVER_2_INTERNAL_IP=$(terraform output -json internal_ip_address_webserver-2 | jq -r '.')
GRAFANA_INTERNAL_IP=$(terraform output -json internal_ip_address_grafana-server | jq -r '.')
KIBANA_INTERNAL_IP=$(terraform output -json internal_ip_address_kibana-server | jq -r '.')
ELASTICSEARCH_INTERNAL_IP=$(terraform output -json internal_ip_address_elasticsearch-server | jq -r '.')
PROMETHEUS_INTERNAL_IP=$(terraform output -json internal_ip_address_prometheus-server | jq -r '.')
BASTION_EXTERNAL_IP=$(terraform output -json external_ip_address_bastion | jq -r '.')
LB_EXTERNAL_IP=$(terraform output -json external_ip_address_web-alb[0].address | jq -r '.')
GRAFANA_EXTERNAL_IP=$(terraform output -json external_ip_address_grafana-server | jq -r '.')
KIBANA_EXTERNAL_IP=$(terraform output -json external_ip_address_kibana-server | jq -r '.')

# Формируем inventory
cat <<EOF > ../Ansible/inventory.ini
[all:vars]
ansible_user=super_user
ansible_ssh_private_key_file=/home/admin/.ssh/id_rsa

[bastion]
bastion-server ansible_host=$BASTION_EXTERNAL_IP

[non_bastion:children]
webservers
elk
monitoring

[non_bastion:vars]
ansible_ssh_common_args='-o ProxyJump={{ansible_user}}@$BASTION_EXTERNAL_IP'

[webservers]
webserver-1 ansible_host=$WEBSERVER_1_INTERNAL_IP 
webserver-2 ansible_host=$WEBSERVER_2_INTERNAL_IP 

[elk]
elasticsearch-server ansible_host=$ELASTICSEARCH_INTERNAL_IP 
kibana-server ansible_host=$KIBANA_INTERNAL_IP 

[monitoring]
prometheus-server ansible_host=$PROMETHEUS_INTERNAL_IP 
grafana-server ansible_host=$GRAFANA_INTERNAL_IP 

EOF

# Добавляем в шаблон nginx внешние IP чтобы можно было их использовать для формирования страницы с информацией.

cat <<EOF > ../Ansible/nginx_for_webservers/defaults/main.yml
---
# defaults file for nginx_for_webservers
page_title: "Добро пожаловать на мой сайт"
content_heading: "Информационный сайт по курсовой работе"
content_body: "*ссылки на внешние сервисы, которые доступны из интернета"

bastion_host_info: "bastion-host внешний IP :$BASTION_EXTERNAL_IP"
lb_info: "load-balancer внешний IP :$LB_EXTERNAL_IP"

grafana_info: "UI Grafana доступна по адресу: http://$GRAFANA_EXTERNAL_IP:3000"
kibana_info: "UI Kibana доступна по адресу: http://$KIBANA_EXTERNAL_IP:5601"

EOF