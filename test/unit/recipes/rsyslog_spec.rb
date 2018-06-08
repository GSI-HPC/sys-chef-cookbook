describe 'sys::rsyslog' do
  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'attributes are empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['rsyslog'] = {
          filter:    '*.*,schnubbel.!=dibu',
          server_ip: '1.2.3.4',
          protocol:  'udp',
          port:      56789
        }
      end.converge(described_recipe)
    end

    it 'installs package rsyslog' do
      expect(chef_run).to install_package('rsyslog')
    end

    it 'manages file /etc/rsyslog.conf' do
      expect(chef_run).to create_template('/etc/rsyslog.conf')
      expect(chef_run.template('/etc/rsyslog.conf'))
        .to notify('service[rsyslog]').to(:restart)
    end

    it 'defines loghost forward' do
      expect(chef_run).to render_file('/etc/rsyslog.d/loghost.conf')
                           .with_content('*.*,schnubbel.!=dibu @1.2.3.4:56789')
      expect(chef_run.template('/etc/rsyslog.d/loghost.conf'))
        .to notify('service[rsyslog]').to(:restart)

    end

    it 'manages rsyslog service' do
      expect(chef_run).to enable_service('rsyslog')
    end

  end
end
