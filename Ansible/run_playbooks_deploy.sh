#!/bin/bash

INVENTORY='inventory.ini'
PLAYBOOKS=(
  nginx_deploy.yml
  prometheus_deploy.yml
  node_exporter_deploy.yml
#  nginx_log_ex_deploy.yml
  grafana_deploy.yml
  elasticsearch_deploy.yml
  kibana_deploy.yml
  filebeat_deploy.yml
)

for playbook in "${PLAYBOOKS[@]}"; do
  echo "Running playbook: $playbook"
  ansible-playbook "$playbook" -i "$INVENTORY"
  
  if [ "$?" -ne 0 ]; then
    echo "Playbook $playbook failed. Stopping the script."
    exit 1
  fi
  
  echo "Playbook $playbook finished successfully."
done

echo "All playbooks have been executed successfully."