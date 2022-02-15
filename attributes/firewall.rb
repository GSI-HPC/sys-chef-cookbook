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
  'add table ip6 nat' => 1,
  'add table ip nat' => 1,
  "add chain inet filter INPUT { type filter hook input priority 0 ; policy #{node['sys']['firewall']['defaults']['policy']['input']}; }" => 2,
  "add chain inet filter OUTPUT { type filter hook output priority 0 ; policy #{node['sys']['firewall']['defaults']['policy']['output']}; }" => 2,
  "add chain inet filter FOWARD { type filter hook forward priority 0 ; policy #{node['sys']['firewall']['defaults']['policy']['forward']}; }" => 2,
  'add chain ip nat POSTROUTING { type nat hook postrouting priority 100 ;}' => 2,
  'add chain ip nat PREROUTING { type nat hook prerouting priority -100 ;}' => 2,
  'add chain ip6 nat POSTROUTING { type nat hook postrouting priority 100 ;}' => 2,
  'add chain ip6 nat PREROUTING { type nat hook prerouting priority -100 ;}' => 2,
}
