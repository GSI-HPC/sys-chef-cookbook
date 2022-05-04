default['sys']['firewall']['manage'] = false
default['sys']['firewall']['disable'] = true
default['sys']['firewall']['allow_ssh'] = true
default['sys']['firewall']['allow_loopback'] = true
default['sys']['firewall']['allow_icmp'] = true
default['sys']['firewall']['allow_established'] = true
default['sys']['firewall']['defaults']['policy'] = {
  'input'   => 'drop',
  'forward' => 'drop',
  'output'  => 'accept',
}
default['sys']['firewall']['defaults']['ruleset'] = {
  'add table inet filter' => 1,
  "add chain inet filter input { type filter hook input priority 0 ; policy #{node['sys']['firewall']['defaults']['policy']['input']}; }" => 2,
  "add chain inet filter output { type filter hook output priority 0 ; policy #{node['sys']['firewall']['defaults']['policy']['output']}; }" => 2,
  "add chain inet filter forward { type filter hook forward priority 0 ; policy #{node['sys']['firewall']['defaults']['policy']['forward']}; }" => 2,
}

if node['sys']['firewall']['table_ip_nat']
  default['sys']['firewall']['defaults']['ruleset']['add table ip nat'] = 1
  default['sys']['firewall']['defaults']['ruleset']['add chain ip nat postrouting { type nat hook postrouting priority 100 ;}'] = 2
  default['sys']['firewall']['defaults']['ruleset']['add chain ip nat prerouting { type nat hook prerouting priority -100 ;}'] = 2
end

if node['sys']['firewall']['table_ip6_nat']
  default['sys']['firewall']['defaults']['ruleset']['add table ip6 nat'] = 1
  default['sys']['firewall']['defaults']['ruleset']['add chain ip6 nat postrouting { type nat hook postrouting priority 100 ;}'] = 2
  default['sys']['firewall']['defaults']['ruleset']['add chain ip6 nat prerouting { type nat hook prerouting priority -100 ;}'] = 2
end
