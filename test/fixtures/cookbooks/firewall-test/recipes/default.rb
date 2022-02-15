include_recipe 'sys::firewall'

firewall_rule 'ssh22' do
  port 22
  command :allow
end

firewall_rule 'port array' do
  port [2222, 2200]
  command :allow
end

firewall_rule 'range' do
  port 1000..1100
  command :allow
end

firewall_rule 'range-udp' do
  port 60000..61000
  protocol :udp
end

firewall_rule 'ping6' do
  protocol :icmpv6
end

# other rules
firewall_rule 'temp1' do
  port 1234
  command :deny
end

firewall_rule 'temp2' do
  port 1235
  command :reject
end

firewall_rule 'addremove' do
  port 1236
  command :allow
end

firewall_rule 'addremove2' do
  port 1236
  command :deny
end

firewall_rule 'protocolnum' do
  protocol 112
  command :allow
end

firewall_rule 'prepend' do
  port 7788
  position 5
end

firewall_rule "block single ip" do
  source '192.168.99.99'
  position 49
  command :reject
end

firewall_rule 'block ip-range' do
  source ['192.168.99.99', '192.168.100.100']
  command :drop
end

firewall_rule 'ipv6-source' do
  port 80
  family :ip6
  source '2001:db8::ff00:42:8329'
  command :allow
end

firewall_rule 'array' do
  port [1234, 5000..5100, '5678']
  command :allow

end

firewall_rule 'RPC Port Range In' do
  port 5000..5100
  protocol :tcp
  command :allow
  direction :in

end

firewall_rule 'HTTP HTTPS' do
  port [80, 443]
  protocol :tcp
  direction :out
  command :allow
end

firewall_rule 'port2433' do
  description 'This should not be included'
  include_comment false
  source    '127.0.0.0/8'
  port      2433
  direction :in
  command   :allow
end

firewall_rule 'esp' do
  protocol :esp
  command :allow
end

firewall_rule 'ah' do
  protocol :ah
  command :allow
end

firewall_rule 'esp-ipv6' do
  source '::'
  family :ip6
  protocol :esp
  command :allow
end

firewall_rule 'ah-ipv6' do
  source '::'
  family :ip6
  protocol :ah
  command :allow
end

firewall_rule 'redirect' do
  direction :pre
  port 5555
  redirect_port 6666
  command :redirect
end
