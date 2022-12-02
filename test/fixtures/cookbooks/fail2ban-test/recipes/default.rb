nftables 'default'

nftables_rule 'allow loopback' do
  interface 'lo'
  protocol :none
  command :allow
end

nftables_rule 'allow icmp' do
  protocol :icmp
  command :allow
end

# allow established connections
nftables_rule 'established' do
  position 40
  stateful [:related, :established]
  protocol :none # explicitly don't specify protocol
  command :allow
end


nftables_rule 'ssh22' do
  dport 22
end

include_recipe 'sys::fail2ban'
