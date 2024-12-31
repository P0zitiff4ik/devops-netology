output "lb_ip" {
  value       = flatten([for l in yandex_lb_network_load_balancer.network-lb.listener : [for e in l.external_address_spec : e.address if l.name == "http"]])[0]
  description = "lb_ext_network_interface"
}
