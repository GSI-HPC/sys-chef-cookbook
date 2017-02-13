describe 'sys::smartd' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'without related attributes' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with smartd enabled' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    before do
      chef_run.node.default['sys']['smartd']['enable'] = true
      chef_run.node.default['sys']['smartd']['mailto'] = 'doedel@xyz.io'
      chef_run.converge(described_recipe)
    end

    it 'does stuff' do
      pkg_name = 'smartmontools'
      expect(chef_run).to install_package(pkg_name)
      expect(chef_run).to create_template("/etc/default/#{pkg_name}")

      # service name is smartd, differing from Debian's defaults:
      srv_name = 'smartd'
      expect(chef_run).to enable_service(srv_name)
      expect(chef_run).to start_service(srv_name)
    end

    it 'configures mail alerts' do
      expect(chef_run).to render_file('/etc/smartd.conf')
                           .with_content(/DEVICESCAN .* -m doedel@xyz.io .*/)
    end
  end

  context 'inside a VM' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    before do
      chef_run.node.default['sys']['smartd']['enable'] = true
      chef_run.node.automatic['virtualization']['role'] = 'guest'
      chef_run.converge(described_recipe)
    end

    it 'emits a warning' do
      expect(chef_run).to write_log(/ not enabling smartd/)
    end

  end
end
