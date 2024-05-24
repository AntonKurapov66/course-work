#output bastion
output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}
output "internal_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}
output "FQDN_bastion" {
  value = yandex_compute_instance.bastion.fqdn
}
#output webserver-1
output "internal_ip_address_webserver-1" {
  value = yandex_compute_instance.webserver-1.network_interface.0.ip_address
}
output "external_ip_address_webserver-1" {
  value = yandex_compute_instance.webserver-1.network_interface.0.nat_ip_address
}
output "FQDN_webserver-1" {
  value = yandex_compute_instance.webserver-1.fqdn
}
#output webserver-2
output "internal_ip_address_webserver-2" {
  value = yandex_compute_instance.webserver-2.network_interface.0.ip_address
}
output "external_ip_address_webserver-2" {
  value = yandex_compute_instance.webserver-2.network_interface.0.nat_ip_address
}
output "FQDN_webserver-2" {
  value = yandex_compute_instance.webserver-2.fqdn
}
#output grafana
output "external_ip_address_grafana-server" {
  value = yandex_compute_instance.grafana-server.network_interface.0.nat_ip_address
}
output "internal_ip_address_grafana-server" {
  value = yandex_compute_instance.grafana-server.network_interface.0.ip_address
}
output "FQDN_grafana-server" {
  value = yandex_compute_instance.grafana-server.fqdn
}
#output kibana
output "external_ip_address_kibana-server" {
  value = yandex_compute_instance.kibana-server.network_interface.0.nat_ip_address
}
output "internal_ip_address_kibana-server" {
  value = yandex_compute_instance.kibana-server.network_interface.0.ip_address
}
output "FQDN_kibana-server" {
  value = yandex_compute_instance.kibana-server.fqdn
}
#output prometheus
output "internal_ip_address_prometheus-server" {
  value = yandex_compute_instance.prometheus-server.network_interface.0.ip_address
}
output "FQDN_prometheus-server" {
  value = yandex_compute_instance.prometheus-server.fqdn
}
#output elasticsearch
output "internal_ip_address_elasticsearch-server" {
  value = yandex_compute_instance.elasticsearch-server.network_interface.0.ip_address
}
output "FQDN_elasticsearch-server" {
  value = yandex_compute_instance.elasticsearch-server.fqdn
}
#output load balancer
output "external_ip_address_web-alb" {
  value = yandex_alb_load_balancer.web-alb.listener.0.endpoint.0.address.0.external_ipv4_address
}