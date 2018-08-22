describe 'sys::chef' do
  context 'attributes are empty' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'does nothing' do
      expect(chef_run).to write_log('no_chef_server').with(level: :warn)
    end
  end

  context 'with attributes' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['chef'] = {
          server_url: 'http://bocuse.example.com:2345',
          restart_via_cron: true
        }
      end.converge(described_recipe)
    end

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/etc/chef/client.pem')
                      .and_return(true)
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with('/etc/rc2.d/*chef-client*')
                     .and_return([])
    end

    it 'writes default file' do
      expect(chef_run).to create_template('/etc/default/chef-client')
    end

    it 'writes client.rb' do
      expect(chef_run).to create_template('/etc/chef/client.rb')
    end

    it 'writes logrotate config' do
      expect(chef_run).to create_template('/etc/logrotate.d/chef')
    end

    it 'cleans up validation key' do
      expect(chef_run).to delete_file(
                            chef_run.node['sys']['chef']['validation_key']
                          )
    end

    it 'manages permissions of client key' do
      expect(chef_run).to create_file(
                            chef_run.node['sys']['chef']['client_key']
                          ).with(
                            group: chef_run.node['sys']['chef']['group'],
                            mode:  0o640
                          )
    end

    it 'writes logrotate config' do
      expect(chef_run).to create_template('/etc/cron.hourly/chef-client')
                           .with_mode(0o755)
    end

    it 'enables and starts chef-client service' do
      expect(chef_run).to enable_service('chef-client')
      expect(chef_run).to start_service('chef-client')
    end
  end
end
