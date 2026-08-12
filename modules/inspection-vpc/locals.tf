locals {
  firewall_endpoint_id_a = [
    for state in aws_networkfirewall_firewall.this.firewall_status[0].sync_states :
    state.attachment[0].endpoint_id
    if state.availability_zone == var.availability_zone_a
  ][0]

  firewall_endpoint_id_b = [
    for state in aws_networkfirewall_firewall.this.firewall_status[0].sync_states :
    state.attachment[0].endpoint_id
    if state.availability_zone == var.availability_zone_b
  ][0]
}
