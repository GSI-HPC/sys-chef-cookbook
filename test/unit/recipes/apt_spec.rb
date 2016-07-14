describe 'sys::apt' do
  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  before do
    @apt_update = 'apt-get -qq update'
  end

  it 'has an execute resource for apt-get update' do
    res = chef_run.find_resource(:execute, @apt_update)
    expect(res).to do_nothing
  end

  context 'node.sys.apt is empty' do
    it 'does not add multiarch support' do
      res = chef_run.find_resource(:execute, 'dpkg --add-architecture i386')
      expect(res).to do_nothing
    end

    it 'does nothing else' do
      all = chef_run.run_context.resource_collection.all_resources
      expect(all.size).to eq(3)
      expect(all[0].command).to eq('dpkg --configure -a')
      expect(all[1].command).to eq('apt-get -qq update')
      expect(all[2].command).to eq('dpkg --add-architecture i386')
    end
  end

  context 'dpkg was interrupted' do
    cached(:chef_run) do
      # fake left-overs from an interrupted dpkg run:
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with('/var/lib/dpkg/updates/*')
                     .and_return(['/007'])
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    xit 'runs dpkg --configure -a' do
      expect(chef_run).to run_execute('dpkg --configure -a')
    end
  end

  context 'node.sys.apt.packages is not empty' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['apt']['packages'] = [ 'example' ]
      end.converge(described_recipe)
    end

    it 'installs packages' do
      expect(chef_run).to install_package('example')
    end
  end

  context 'node.sys.apt.keys is not empty' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['sys_apt_key']) do |node|
        node.default['sys']['apt']['keys']['remove'] = ['8619D7577AD88F7DE0A9DD018353CCB474EFCA61']
        @key = '-----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: GnuPG v1.4.10 (GNU/Linux)

          mQGiBEtwDoURBACtcaK80IOtBaLtvJvwUYDy2gVD5W05vfx9fSSil8hZDpDL4ZMn
          qBghE1TqfHWJSwIz9wvkmUbqEykz16DepjkRqDTTmKbsjwoPsPU/Sp6Mt8X7KtDd
          Tt29z9RAN9cXGVStjlCpnGb0eLl/mt12KUJKQxzc8lDRHA9xMzOomjfkHwCgsUT8
          +LwpbqCxZUJS/KD973arRzUEAKKvFvvzHXNYMOBEdSVYjUKtW2RsOyxLmhNJTxnz
          GaKi/PB/cNVx1PbqDg61f82K1YG8DIWJGEAlNoNanaTt3Ml71jZ6JQuh9E9P99RK
          TsfhYO9Gr3tiGUEYIr174eha+Eu0u3oCVhJVo6ML39XAjKyZCDVxo8e0rPtd/PYq
          x5VpBACM6eXQeYr/Cp/TL42PsWyTa+dgX942FcZzrrEFQLJins8VRvuZ1joB0vdw
          PSVw8LrD8NZ0+JVBj89yHTjaCbhoE7SACEHJejQHMrckLD5FsAXmrWxH3PbRFd8j
          H+K1IQAbdvBdpYHQArm0GYJ+Mhum+7sU67ZvCMWljlnzBRhxUbQzR1NJIHJlcG9z
          aXRvcnkgc2lnbmluZyBrZXkgMjAxMCA8bGludXhncm91cEBnc2kuZGU+iGAEExEC
          ACAFAktwDoUCGwMGCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRAkSsogoCBqzBht
          AJwLfEpsyussPMcHy/lsYw7Up7NAvACgjfRMKLZXfn5ZkgHs3Y31sR6J2MC5Ag0E
          S3AOhRAIANC3CiHFTEIpe1N3CRBpWKbxUPKKQAU6gDGikp/EXRn2n3PpqH/zJ0Bj
          1//OzVYmgPl/y7KwLEAiEqrABwdliXvykD/w6Cu8dE9Tre1xSHnZ2u7IbnfIvu0x
          I4jViBC1SXvwQNyKIy/rNtny+rBZf2TuCrEJFIzXfD6Cdfu6oOgMG4xI+ehzsNjb
          qSQ7GuIEgTi4itYC0l+zXmCN3/hFmfj2EBVOKmKZfm6w9PHYUAOXrGGeV5a8kFbG
          GQ5rUin8DGpCc/PsM2QtuJCxeWiUFGBAqEmHYPkClwMjONMR9w+YmM7we5fquubr
          0f6EsMlpQOpGaHqrBuGgoPxy/3jSpZsAAwYH/j0qB6fSs0i5Q6eC+8kSZKY7ljaF
          XsyqHmNeJG8opUVVgGMaKx4jHvzxeDfpQp1ekbRv1Eo4ZOgP4b1m2IWh48IxolsV
          lJav6qab8rZ7DoUa7gWxOtqD08x/VImYOOPmkeRk7Mz7a61RPmVqWYkV0WXZg7R+
          59VAHT41cQRd3cT8wk6FYev4gwKEy5QAPCpbuo2pRC6Lcs5xCruE70PFxes1DS8R
          ylcF66M4QZ8AmWJNESAqjLUuAQ0iwKIK32Jr646OnceACMm3g+JY9MzSoY4DypV5
          yvSYC5WfVU6bdSjPNiOidG9GSj44R3dJcaU4latdGaA3ajVI/VGmyHnpm9+ISQQY
          EQIACQUCS3AOhQIbDAAKCRAkSsogoCBqzNN3AJ9Hvc+p2JXd6RhdqK61UZO4A37c
          DACcCQ6b+3LKKrdlfy5xAQ/BYVdAxeA=
          =GI6g
          -----END PGP PUBLIC KEY BLOCK-----
          '.gsub(/^ */,'')
        node.default['sys']['apt']['keys']['add'] = [ @key ]
      end.converge(described_recipe)
    end

    before do
      stub_command("apt-key list | grep '74EFCA61' >/dev/null").and_return(true)
    end

    it 'manages APT keys (remove first, then add)' do

      add_resource = '0: Deploy APT package signing key'
      expect(chef_run).to add_sys_apt_key(add_resource)
      remove_resource = '0: Remove APT apckage signing key'
      expect(chef_run).to remove_sys_apt_key(remove_resource)

      # check the order
      add = chef_run.find_resource(:sys_apt_key, add_resource)
      remove = chef_run.find_resource(:sys_apt_key, remove_resource)
      add_index = chef_run.run_context.resource_collection.all_resources.index(add)
      remove_index = chef_run.run_context.resource_collection.all_resources.index(remove)
      expect(add_index).to be < remove_index
    end
  end

  context 'node.sys.apt.repositories is not empty' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(log_level: :error, step_into: ['sys_apt_repository']) do |node|
        node.default['sys']['apt']['repositories']['foo'] = 'bar'
      end.converge(described_recipe)
    end

    it 'manages /etc/apt/sources.list.d/*' do
      expect(chef_run).to add_sys_apt_repository('foo')

      file = '/etc/apt/sources.list.d/foo.list'
      res = chef_run.find_resource(:template, file)
      expect(res).to notify("execute[#{@apt_update}]").to(:run).immediately
      expect(chef_run).to create_template(file)
    end
  end

  context 'node.sys.apt.preferences is not empty' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(log_level: :error, step_into: ['sys_apt_preference']) do |node|
        node.default['sys']['apt']['preferences']['foopref'] = {
          'package' => 'foobar',
          'pin' => 'version 666',
          'priority' => 1001
        }
      end.converge(described_recipe)
    end

    it 'manages /etc/apt/preferences.d/*' do
      expect(chef_run).to set_sys_apt_preference('foopref').with_package('foobar').with_pin('version 666').with_priority(1001)

      file = '/etc/apt/preferences.d/foopref'
      res = chef_run.find_resource(:template, file)
      expect(res).to notify("execute[#{@apt_update}]").to(:run).immediately
      expect(chef_run).to create_template(file).with_mode('0644').with_variables({
        :name => 'foopref',
        :package => 'foobar',
        :pin => 'version 666',
        :priority => 1001
      })
      expect(chef_run).to render_file(file).with_content('Package: foobar')
    end
  end

  context 'node.sys.apt.config is not empty' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(log_level: :error, step_into: ['sys_apt_conf']) do |node|
        node.default['sys']['apt']['config']['fooconf'] = { 'foo' => 'bar' }
      end.converge(described_recipe)
    end

    it 'manages /etc/apt/apt.conf.d/*' do
      expect(chef_run).to set_sys_apt_conf('fooconf')

      file = '/etc/apt/apt.conf.d/fooconf'
      res = chef_run.find_resource(:template, file)
      expect(res).to notify("execute[#{@apt_update}]").to(:run).immediately
      expect(chef_run).to create_template(file).with_mode('0644')
    end
  end
end
