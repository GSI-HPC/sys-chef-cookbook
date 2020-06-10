describe 'sys::multipath' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.multipath is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['multipath']['defaults']['user_friendly_names'] =
          'yes'
      end.converge(described_recipe)
    end

    it 'installs multipath-tools' do
      expect(chef_run).to install_package('multipath-tools')
    end

    it 'manages service multipath-tools' do
      expect(chef_run).to enable_service('multipath-tools')
      expect(chef_run).to start_service('multipath-tools')
    end

    it 'manages /etc/multipath.conf' do
      expect(chef_run).to create_template('/etc/multipath.conf')
      resource = chef_run.template('/etc/multipath.conf')
      expect(resource).to notify('service[multipath-tools]').to(:reload)
      expect(chef_run).to render_file('/etc/multipath.conf').with_content(/defaults {\n     user_friendly_names yes\n}\n/)
    end

    it 'does not regenerate initramdisk by default' do
      execute = chef_run.execute('regenerate-initramdisk')
      expect(execute).to do_nothing
      resource = chef_run.template('/etc/multipath.conf')
      expect(resource).not_to notify('execute[regenerate-initramdisk]').to(:run)
    end
  end

  context 'with root fs relevant config' do
    before do
      chef_run.node.default['sys']['multipath']['defaults']['user_friendly_names'] = 'yes'
      chef_run.node.default['sys']['multipath']['regenerate_initramdisk'] = true
      chef_run.converge(described_recipe)
    end

    it 'does regenerate initramdisk' do
      execute = chef_run.execute('regenerate-initramdisk')
      expect(execute).to do_nothing
      resource = chef_run.template('/etc/multipath.conf')
      expect(resource).to notify('execute[regenerate-initramdisk]').to(:run)
    end
  end
end
