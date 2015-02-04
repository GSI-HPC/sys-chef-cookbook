describe 'sys::network' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.network.interfaces is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    before do
      chef_run.node.default['sys']['network']['interfaces'] = {
        "eth0" => { "inet" => "dhcp" },
        "eth1" => {
          "inet" => "static",
          "address" => "10.1.1.4",
          "netmask" => "255.255.255.0",
          "broadcast" => "10.1.1.255",
          "gateway" => '10.1.1.1',
          "up" => "route add -net 10.0.0.0 netmask 255.0.0.0 gw 10.8.0.1",
          "down" => "down route del -net 10.0.0.0 netmask 255.0.0.0 gw 10.8.0.1"
        },
        "vlan1" => {
          "vlan_raw_device" => "eth0",
          "up" => "ifup br1"
        },
        "br1" => {
          "auto" => false,
          "bridge_ports" => "vlan1"
        }
      }
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/network/interfaces.d/*' do
      path = '/etc/network/interfaces.d/'
      expect(chef_run).to create_template("#{path}eth0").with_mode("0644")
      expect(chef_run).to create_template("#{path}eth1").with_mode("0644")
      expect(chef_run).to create_template("#{path}vlan1").with_mode("0644")
      expect(chef_run).to create_template("#{path}br1").with_mode("0644")
    end
  end

  context 'node.sys.network.vlan_bridges is not empty' do
    before do
      chef_run.node.default['sys']['network']['vlan_bridges'] = [ 7 ]
      chef_run.converge(described_recipe)
    end

    it 'configures vlan bridges' do
      path = '/etc/network/interfaces.d/'
      expect(chef_run).to create_template("#{path}eth0.7")
      expect(chef_run).to create_template("#{path}br7")
    end
  end
end
