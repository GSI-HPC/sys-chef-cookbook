describe 'sys::kernel' do
  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'attributes are empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'on Intel' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['kernel']['install_microcode'] = true
        node.automatic['cpu']['0']['vendor_id'] = 'GenuineIntel'
      end.converge(described_recipe)
    end

    it 'installs microcode package' do
      expect(chef_run).to install_package('intel-microcode')
    end
  end

  context 'on AMD' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['kernel']['install_microcode'] = true
        node.automatic['cpu']['0']['vendor_id'] = 'AuthenticAMD'
      end.converge(described_recipe)
    end

    it 'installs microcode package' do
      expect(chef_run).to install_package('amd64-microcode')
    end
  end

end
