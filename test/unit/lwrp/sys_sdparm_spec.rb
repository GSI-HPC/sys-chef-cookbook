describe 'lwrp: sys_sdparm' do

  let(:cookbook_paths) do
    [
      File.expand_path("#{File.dirname(__FILE__)}/../../../../"),
      File.expand_path("#{File.dirname(__FILE__)}/../")
    ]
  end

  let(:runner) do
    ChefSpec::ServerRunner.new(
      :cookbook_path => cookbook_paths,
      :step_into => ['sys_sdparm']
    )
  end

  describe 'action :set' do
    let(:chef_run) { runner.converge('fixtures::sys_sdparm_set') }

    it 'installs sdparm' do
      expect(chef_run).to install_package('sdparm')
    end

    context '2 disks, both WCE cleared' do
      before do
        @flag = 'WCE'
        @disks = '/dev/sd*'
        @fake_disks = {
          '/dev/sda' => { save: '0', default: '0' },
          '/dev/sdb' => { save: '0', default: '0' }
        }
        prepare_disks(@flag, @disks, @fake_disks)
      end

      it 'sets WCE on both disks' do
        expect(chef_run).to run_execute(sdparm('set', @flag, @fake_disks.keys.join(' ')))
      end
    end

    context '2 disks, first WCE cleared' do
      before do
        @flag = 'WCE'
        @disks = '/dev/sd*'
        @fake_disks = {
          '/dev/sda' => { save: '0', default: '0' },
          '/dev/sdb' => { save: '1', default: '0' }
        }
        prepare_disks(@flag, @disks, @fake_disks)
      end

      it 'sets WCE on first disk' do
        expect(chef_run).to run_execute(sdparm('set', @flag, @fake_disks.keys.first))
      end
    end

    context '2 disks, none WCE cleared' do
      before do
        @flag = 'WCE'
        @disks = '/dev/sd*'
        @fake_disks = {
          '/dev/sda' => { save: '1', default: '0' },
          '/dev/sdb' => { save: '1', default: '0' }
        }
        prepare_disks(@flag, @disks, @fake_disks)
      end

      it 'does not set WCE on any disk' do
        chef_run.run_context.resource_collection.each do |res|
          expect(res).not_to be_kind_of(Chef::Resource::Execute)
        end
      end
    end
  end

  describe 'action :clear' do
    let(:chef_run) { runner.converge('fixtures::sys_sdparm_clear') }

    it 'installs sdparm' do
      expect(chef_run).to install_package('sdparm')
    end

    context '3 disks, all WCE set' do
      before do
        @flag = 'WCE'
        @disks = '/dev/sd*'
        @fake_disks = {
          '/dev/sda' => { save: '1', default: '0' },
          '/dev/sdb' => { save: '1', default: '0' },
          '/dev/sdc' => { save: '1', default: '0' }
        }
        prepare_disks(@flag, @disks, @fake_disks)
      end

      it 'clears WCE on all disks' do
        expect(chef_run).to run_execute(sdparm('clear', @flag, @fake_disks.keys.join(' ')))
      end
    end

    context '2 disks, first WCE cleared' do
      before do
        @flag = 'WCE'
        @disks = '/dev/sd*'
        @fake_disks = {
          '/dev/sda' => { save: '0', default: '0' },
          '/dev/sdb' => { save: '1', default: '0' }
        }
        prepare_disks(@flag, @disks, @fake_disks)
      end

      it 'clears WCE on second disk' do
        expect(chef_run).to run_execute(sdparm('clear', @flag, @fake_disks.keys[1]))
      end
    end

    context '4 disks, all WCE cleared' do
      before do
        @flag = 'WCE'
        @disks = '/dev/sd*'
        @fake_disks = {
          '/dev/sda' => { save: '0', default: '0' },
          '/dev/sdb' => { save: '0', default: '0' },
          '/dev/sdc' => { save: '0', default: '0' },
          '/dev/sdd' => { save: '0', default: '0' }
        }
        prepare_disks(@flag, @disks, @fake_disks)
      end

      it 'does not clear WCE on any disk' do
        chef_run.run_context.resource_collection.each do |res|
          expect(res).not_to be_kind_of(Chef::Resource::Execute)
        end
      end
    end
  end

  describe 'action :restore_default' do
    let(:chef_run) { runner.converge('fixtures::sys_sdparm_restore_default') }

    it 'installs sdparm' do
      expect(chef_run).to install_package('sdparm')
    end

    context '4 disks with various defaults and saved states' do
      before do
        @flag = 'WCE'
        @disks = '/dev/sd*'
        @fake_disks = {
          '/dev/sda' => { save: '1', default: '1' },
          '/dev/sdb' => { save: '0', default: '1' },
          '/dev/sdc' => { save: '1', default: '0' },
          '/dev/sde' => { save: '0', default: '0' }
        }
        prepare_disks(@flag, @disks, @fake_disks)
      end

      it 'sets/clears to default if necessary' do
        expect(chef_run).to run_execute(sdparm('set', @flag, @fake_disks.keys[1]))
        expect(chef_run).to run_execute(sdparm('clear', @flag, @fake_disks.keys[2]))

        executes = chef_run.run_context.resource_collection.select { |res| res.kind_of?(Chef::Resource::Execute) }
        expect(executes.count).to eq 2
      end
    end
  end
end

def prepare_disks(flag, disks, fake_disks)
  # Generate fake output
  fakeout = ''
  fake_disks.each do |disk, prop|
    fakeout << "    #{disk}: WD        WD3001FYYG-01SL3  VR07\n#{flag}         #{prop[:save]}  [cha: y, def:  #{prop[:default]}, sav:  #{prop[:save]}]\n"
  end

  # Mock sdparm --get call
  allow(Mixlib::ShellOut).to receive(:new).and_call_original
  allow(Mixlib::ShellOut).to receive(:new).with("sdparm --get=#{flag} #{disks}") do
    instance_double('Mixlib::ShellOut',
                    'sdparm_get',
                    run_command: true,
                    stdout: fakeout)
  end
end

def sdparm(method, flag, disks)
  "sdparm --#{method}=#{flag} --save --quiet #{disks}"
end
