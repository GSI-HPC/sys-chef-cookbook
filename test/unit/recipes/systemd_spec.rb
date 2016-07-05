describe 'sys::systemd' do

  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  before do
    allow(Mixlib::ShellOut).to receive(:new).and_call_original
    allow(Mixlib::ShellOut).to receive(:new).with('cat /proc/1/comm').and_return(
      double(run_command: nil, stdout: "systemd\n")
    )
    allow(Mixlib::ShellOut).to receive(:new).with('dpkg -s systemd-sysv').and_return(
      double(run_command: nil, exitstatus: 0)
    )
    allow(Mixlib::ShellOut)
      .to receive(:new).with('systemctl enable systemd-networkd.service')
           .and_return(double(run_command: nil, exitstatus: 0))
  end

  context 'node.sys.systemd is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do

    let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['sys_systemd_unit']) }

    before do
      chef_run.node.default['sys']['systemd']['networkd']['enable'] = true
      chef_run.node.default['sys']['systemd']['networkd']['clean_legacy'] = true
      allow(Dir).to receive(:[]).and_call_original
      allow(Dir).to receive(:[]).with('/etc/network/interfaces.d/*').and_return(
        double(empty?: false)
      )
      chef_run.node.default['sys']['systemd']['unit']['test'] = {
        'type' => 'mount',
        'config' => {
          'Unit' => {
            'Description' => 'Dummy'
          }
        },
        'action' => [:enable, :start, :reload]
      }
      chef_run.converge(described_recipe)
    end

    it 'manages systemd-networkd.service' do
      expect(chef_run).to enable_service('systemd-networkd')
      expect(chef_run).to start_service('systemd-networkd')
    end

    it 'cleans legacy network config' do
      expect(chef_run).to run_execute('rm -rf /etc/network/interfaces.d/*')
      expect(chef_run).to create_file('/etc/network/interfaces')
    end

    it 'manages systemd units from attributes' do
      expect(chef_run).to enable_sys_systemd_unit('test')
      expect(chef_run).to start_sys_systemd_unit('test')
      expect(chef_run).to reload_sys_systemd_unit('test')
      expect(chef_run).to run_execute('systemctl enable test.mount')
      expect(chef_run).to run_execute('systemctl start test.mount')
    end
  end
end
