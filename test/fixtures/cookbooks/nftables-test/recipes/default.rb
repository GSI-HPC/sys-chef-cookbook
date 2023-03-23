return unless Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

nftables 'default' do
  table_ip_nat true
  table_ip6_nat true
  input_policy 'drop'
end

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

nftables_rule 'named set' do
  position 39
  raw "add set inet filter networks { type ipv4_addr; flags constant, interval; elements={ 192.0.2.0/24 } }"
end

nftables_rule 'variable' do
  raw 'define quad9 = 9.9.9.9'
end

nftables_rule 'test named set' do
  source '@networks'
end

nftables_rule 'ssh22' do
  dport 22
end

nftables_rule 'port array' do
  dport [2222, 2200]
  command :allow
end

nftables_rule 'range' do
  dport 1000..1100
  command :allow
end

nftables_rule 'range-udp' do
  dport 60000..61000
  protocol :udp
end

nftables_rule 'ping6' do
  protocol :icmpv6
end

# other rules
nftables_rule 'temp1' do
  dport 1234
  command :deny
end

nftables_rule 'temp2' do
  dport 1235
  command :reject
end

nftables_rule 'addremove' do
  dport 1236
  command :allow
end

nftables_rule 'addremove2' do
  dport 1236
  command :deny
end

nftables_rule 'protocolnum' do
  protocol 112
  command :allow
end

nftables_rule 'prepend' do
  dport 7788
  position 5
end

nftables_rule "block single ip" do
  source '192.168.99.99'
  position 49
  command :reject
end

nftables_rule 'block ip-range' do
  source ['192.168.99.99', '192.168.100.100']
  command :drop
end

nftables_rule "block single destination ip" do
  destination '192.168.99.99'
  position 49
  command :reject
end

nftables_rule 'block destination ip-range' do
  destination ['192.168.99.99', '192.168.100.100']
  command :drop
end

nftables_rule 'ipv6-source' do
  dport 80
  family :ip6
  source '2001:db8::ff00:42:8329'
  command :allow
end

nftables_rule 'array' do
  dport [1234, 5000..5100, '5678']
  command :allow

end

nftables_rule 'RPC Port Range In' do
  dport 5000..5100
  protocol :tcp
  command :allow
  direction :in

end

nftables_rule 'HTTP HTTPS' do
  dport [80, 443]
  protocol :tcp
  direction :out
  command :allow
end

nftables_rule 'port2433' do
  description 'This should not be included'
  include_comment false
  source    '127.0.0.0/8'
  dport      2433
  direction :in
  command   :allow
end

nftables_rule 'esp' do
  protocol :esp
  command :allow
end

nftables_rule 'ah' do
  protocol :ah
  command :allow
end

nftables_rule 'esp-ipv6' do
  source '::'
  family :ip6
  protocol :esp
  command :allow
end

nftables_rule 'ah-ipv6' do
  source '::'
  family :ip6
  protocol :ah
  command :allow
end

nftables_rule 'redirect' do
  direction :pre
  dport 5555
  redirect_port 6666
  command :redirect
end

nftables_rule 'log_without_prefix' do
  dport 1
  command :log
end

nftables_rule 'log_with_prefix' do
  dport 1
  log_prefix 'nflog by chef:'
  log_group 1
  command :log
end

nftables_rule 'multiple commands' do
  dport 2
  command [:counter, :log, :accept]
end
