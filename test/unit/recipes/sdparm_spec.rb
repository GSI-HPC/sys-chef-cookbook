describe 'sys::sdparm' do

  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  context 'node.sys.sdparm is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do

    let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['sys_sdparm']) }

    before do
      chef_run.node.default['sys']['sdparm']['set']['WCE'] = [ '/dev/sd*', '/dev/disk/by-id/*' ]
      chef_run.converge(described_recipe)
    end

    it 'manages scsi disk parameters' do
      expect(chef_run).to install_package('sdparm')
      expect(chef_run).to set_sys_sdparm(chef_run.node['sys']['sdparm']['set']['WCE'].join(' ')).with_flag('WCE')
    end
  end
end
