describe 'sys::ipmi' do

  before(:all) do
    @overheat_script = '/usr/local/sbin/ipmi-setup-overheat-protection'
  end

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'without related attributes' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with attributes defined' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['ipmi']['overheat_protection']['enable'] = true
        node.automatic['ipmi']['pef-config']['Event_Filter_0815'] = { }
      end.converge(described_recipe)
    end

    it 'installs required packages' do
      expect(chef_run).to install_package('ipmitool')
      expect(chef_run).to install_package('freeipmi-tools')
    end

    it 'drops the overheat protection script' do
      expect(chef_run).to create_cookbook_file(@overheat_script)
                           .with(mode: 0o755)
    end

    it 'configures overheat protection' do
      expect(chef_run).to run_execute(@overheat_script)
    end
  end
end
