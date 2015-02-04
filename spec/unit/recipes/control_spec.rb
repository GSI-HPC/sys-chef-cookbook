describe 'sys::control' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.control is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    before do
      chef_run.node.default['sys']['control'] = {
        'net.ipv6' => {
          'conf.all.disable_ipv6' => 1
        }
      }
      chef_run.converge(described_recipe)
      @file_name = '/etc/sysctl.d/net_ipv6.conf'
      @execute_name = 'Set Linux kernel variables from /etc/sysctl.d/net_ipv6.conf'
    end

    it 'manages /etc/sysctl.d/*.conf files' do
      expect(chef_run).to create_file(@file_name).with_mode('0644')
    end

    it 'triggers loading of changed /etc/sysctl.d/*.conf files' do
      res = chef_run.find_resource(:execute, @execute_name)
      expect(res).to do_nothing

      res = chef_run.find_resource(:file, @file_name)
      expect(res).to notify("execute[#{@execute_name}]").to(:run).immediately
    end
  end
end
