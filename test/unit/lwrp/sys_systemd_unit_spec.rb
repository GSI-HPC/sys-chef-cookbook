describe 'lwrp: sys_systemd_unit' do

  let(:cookbook_paths) do
    [
      File.expand_path("#{File.dirname(__FILE__)}/../../../../"),
      File.expand_path("#{File.dirname(__FILE__)}/../")
    ]
  end

  let(:runner) do
    ChefSpec::ServerRunner.new(
      :cookbook_path => cookbook_paths,
      :step_into => ['sys_systemd_unit']
    )
  end

  let(:directory) { '/etc/systemd/network' }
  let(:absolute_path) { '/etc/systemd/network/test.network' }
  let(:unit) { 'test.network' }
  states = [ :enabled, :linked, :masked, :static, :disabled, :unknown ]

  describe 'action :create' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_create') }

    it 'manages the unit file' do
      expect(chef_run).to create_directory(directory)
      expect(chef_run).to create_template(absolute_path)
    end

    context 'unit file exists' do
      before do
        allow_any_instance_of(Chef::Resource::Template).to receive(:updated_by_last_action?).and_return(false)
      end

      it 'does not reload systemd' do
        expect(chef_run).to_not run_execute('systemctl daemon-reload')
      end
    end

    context 'unit file does not exist' do
      before do
        allow_any_instance_of(Chef::Resource::Template).to receive(:updated_by_last_action?).and_return(true)
      end

      it 'reloads systemd' do
        expect(chef_run).to run_execute('systemctl daemon-reload')
      end
    end
  end

  describe 'action :delete' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_delete') }

    it 'manages the unit file' do
      expect(chef_run).to delete_template(absolute_path)
    end

    context 'unit file exists' do
      before do
        allow_any_instance_of(Chef::Resource::Template).to receive(:updated_by_last_action?).and_return(true)
      end

      it 'reloads systemd' do
        expect(chef_run).to run_execute('systemctl daemon-reload')
      end
    end

    context 'unit file does not exist' do
      before do
        allow_any_instance_of(Chef::Resource::Template).to receive(:updated_by_last_action?).and_return(false)
      end

      it 'does not reload systemd' do
        expect(chef_run).to_not run_execute('systemctl daemon-reload')
      end
    end
  end

  describe 'action :enable' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_enable') }

    positive = [ :masked, :disabled, :unknown ]

    positive.each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'enables it' do
          expect(chef_run).to run_execute("systemctl enable #{unit}")
        end
      end
    end

    (states - positive).each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'does not enable it' do
          expect(chef_run).to_not run_execute("systemctl enable #{unit}")
        end
      end
    end
  end

  describe 'action :disable' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_disable') }

    positive = [ :enabled, :linked ]

    positive.each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'disables it' do
          expect(chef_run).to run_execute("systemctl disable #{unit}")
        end
      end
    end

    (states - positive).each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'does not disable it' do
          expect(chef_run).to_not run_execute("systemctl disable #{unit}")
        end
      end
    end
  end

  describe 'action :start' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_start') }

    context 'unit is active' do
      before { fake_unit_active(unit, 0) }
      it 'do not start it' do
        expect(chef_run).to_not run_execute("systemctl start #{unit}")
      end
    end

    context 'unit is inactive' do
      before { fake_unit_active(unit, 1) }
      it 'start it' do
        expect(chef_run).to run_execute("systemctl start #{unit}")
      end
    end
  end

  describe 'action :stop' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_stop') }

    context 'unit is active' do
      before { fake_unit_active(unit, 0) }
      it 'stop it' do
        expect(chef_run).to run_execute("systemctl stop #{unit}")
      end
    end

    context 'unit is inactive' do
      before { fake_unit_active(unit, 1) }
      it 'do not stop it' do
        expect(chef_run).to_not run_execute("systemctl stop #{unit}")
      end
    end
  end

  describe 'action :reload' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_reload') }

    context 'unit is active' do
      before { fake_unit_active(unit, 0) }
      it 'reload it' do
        expect(chef_run).to run_execute("systemctl reload #{unit}")
      end
    end

    context 'unit is inactive' do
      before { fake_unit_active(unit, 1) }
      it 'do not reload it' do
        expect(chef_run).to_not run_execute("systemctl reload #{unit}")
      end
    end
  end

  describe 'action :restart' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_restart') }

    it 'always restart the unit (implicit start)' do
      expect(chef_run).to run_execute("systemctl restart #{unit}")
    end
  end

  describe 'action :mask' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_mask') }

    negative = [ :masked ]

    negative.each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'do not mask it' do
          expect(chef_run).to_not run_execute("systemctl mask #{unit}")
        end
      end
    end

    (states - negative).each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'mask it' do
          expect(chef_run).to run_execute("systemctl mask #{unit}")
        end
      end
    end
  end

  describe 'action :unmask' do
    let(:chef_run) { runner.converge('fixtures::sys_systemd_unit_unmask') }

    positive = [ :masked ]

    positive.each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'unmask it' do
          expect(chef_run).to run_execute("systemctl unmask #{unit}")
        end
      end
    end

    (states - positive).each do |state|
      context "unit is #{state}" do
        before { fake_unit_state(unit, state) }
        it 'do not unmask it' do
          expect(chef_run).to_not run_execute("systemctl unmask #{unit}")
        end
      end
    end
  end
end

def fake_unit_state(unit, state)
  # see SYSTEMCTL(1)
  state_table = {
    enabled:  { stdout: "enabled\n",  exitstatus: 0 },
    linked:   { stdout: "linked\n",   exitstatus: 1 },
    masked:   { stdout: "masked\n",   exitstatus: 1 },
    static:   { stdout: "static\n",   exitstatus: 0 },
    disabled: { stdout: "disabled\n", exitstatus: 1 },
    unknown:  { stdout: "unknown\n",  exitstatus: 1 }
  }

  # Mock systemctl is-enabled
  allow(Mixlib::ShellOut).to receive(:new).and_call_original
  allow(Mixlib::ShellOut).to receive(:new).with("systemctl is-enabled #{unit}") do
    instance_double('Mixlib::ShellOut',
                    'systemctl',
                    run_command: true,
                    stdout: state_table[state][:stdout],
                    exitstatus: state_table[state][:exitstatus])
  end
end

def fake_unit_active(unit, state)
  # Mock systemctl is-active
  allow(Mixlib::ShellOut).to receive(:new).and_call_original
  allow(Mixlib::ShellOut).to receive(:new).with("systemctl is-active #{unit} --quiet") do
    instance_double('Mixlib::ShellOut',
                    'systemctl',
                    run_command: true,
                    exitstatus: state)
  end
end

def fake_unit_failed(unit, state)
  # Mock systemctl is-failed
  allow(Mixlib::ShellOut).to receive(:new).and_call_original
  allow(Mixlib::ShellOut).to receive(:new).with("systemctl is-failed #{unit} --quiet") do
    instance_double('Mixlib::ShellOut',
                    'systemctl',
                    run_command: true,
                    exitstatus: state)
  end
end
