describe 'sys::multipath' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.multipath is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    before do
      chef_run.node.default['sys']['multipath']['defaults']['user_friendly_names'] = 'yes'
      chef_run.converge(described_recipe)
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
  end
end
