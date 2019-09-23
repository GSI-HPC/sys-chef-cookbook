require 'spec_helper'

describe 'sys::autofs' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  context "with empty node['sys']['autofs']" do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with ldap on stretch' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['autofs']['ldap'] = {
          'searchbase' => 'dc=example,dc=com',
          'servers' => 'ldap.example.com'
        }
      end.converge(described_recipe)
    end

    it 'installs autofs-ldap' do
      expect(chef_run).to install_package('autofs')
      expect(chef_run).to install_package('autofs-ldap')
    end

    it 'does render /etc/auto.master' do
      expect(chef_run).to render_file('/etc/auto.master').with_content('+auto.master')
    end

    it 'manages systemd files' do
      expect(chef_run).to create_sys_systemd_unit('autofs.service')
      expect(chef_run).to create_sys_systemd_unit('k5start-autofs.service')
    end

    it 'does not manage /etc/init.d/autofs' do
      expect(chef_run).not_to render_file('/etc/init.d/autofs')
    end

    it 'manages the autofs service' do
      expect(chef_run).to enable_service('autofs')
      expect(chef_run).to enable_service('k5start-autofs')
      expect(chef_run).to start_service('autofs')
      expect(chef_run).to start_service('k5start-autofs')
    end

    it 'manages /etc/autofs.conf' do
      expect(chef_run).to render_file('/etc/autofs.conf')
                            .with_content(/browse_mode = no/)
                            .with_content(/search_base = dc=example,dc=com/)
                            .with_content(/ldap_uri = ldap:\/\/ldap.example.com/)
                            .with_content(/entry_attribute = automountKey/)
      expect(chef_run).to_not render_file('/etc/autofs.conf')
                            .with_content(/entry_attribute = cn/)
    end

    it 'manages /etc/default/autofs' do
      expect(chef_run).to render_file('/etc/default/autofs').with_content(
        '# This file has been deprecated in favor of /etc/autofs.conf'
      )
    end

    it 'does restart autofs-service on config-change' do
      a = chef_run.template('/etc/autofs_ldap_auth.conf')
      expect(a).to notify('service[autofs]').to(:restart).delayed
    end
  end

  context 'with local auto.master' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['autofs']['maps'] = {
          'map' => { 'options' => '-browse'},
          '/oldmap' => { 'map' => '/some/path/filename' }
        }
        node.default['sys']['autofs']['create_mountpoints'] = ['/test']
      end.converge(described_recipe)
    end

    before do
      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:exists?).with('/map').and_return(false)
    end

    it 'installs autofs' do
      expect(chef_run).to install_package('autofs')
      expect(chef_run).not_to install_package('ldap-autofs')
    end

    it 'renders /etc/auto.master' do
      expect(chef_run).to render_file('/etc/auto.master').with_content('/map autofs.map -browse')
      expect(chef_run).to render_file('/etc/auto.master').with_content('/oldmap autofs.oldmap')
      expect(chef_run).to render_file('/etc/auto.master').with_content('+auto.master')
    end

    it 'creates /test' do
      expect(chef_run).to create_directory('/test')
    end

    it 'manages systemd files' do
      expect(chef_run).to create_sys_systemd_unit('autofs.service')
      expect(chef_run).not_to create_sys_systemd_unit('k5start-autofs.service')
    end

    it 'manages autofs-service' do
      expect(chef_run).to start_service('autofs')
      expect(chef_run).to enable_service('autofs')
    end

    it 'does reload autofs-service on config-change' do
      resource = chef_run.template('/etc/auto.master')
      expect(resource).to notify('service[autofs]').to(:reload).delayed
    end

  end

  context 'with jessie' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'debian', version: '8.9') do |node|
        node.automatic['fqdn'] = 'node.example.com'
        node.default['sys']['autofs']['ldap']['servers'] = [
          'ldap01.example.com', 'ldap02.example.com'
        ]
        node.default['sys']['autofs']['maps'] = {
          'map' => { }
        }
        node.default['sys']['autofs']['ldap']['schema'] = 'rfc2307'
        node.default['sys']['autofs']['ldap']['searchbase'] = 'dc=example,dc=com'
      end.converge(described_recipe)
    end

    it 'manages /etc/auto.master' do
      expect(chef_run).to create_template('/etc/auto.master').with_mode('0644')
      expect(chef_run).to render_file('/etc/auto.master').with_content('/map autofs.map')
      expect(chef_run).to render_file('/etc/auto.master').with_content('+auto.master')
      expect(chef_run).to render_file('/etc/auto.master').with_content('+dir:/etc/auto.master.d')
    end

    it 'manages /etc/init.d/autofs' do
      # only valid for Jessie, systemd utilized on Stretch and beyond
      expect(chef_run).to create_cookbook_file('/etc/init.d/autofs').with_mode('0755')
    end

    it 'does not manage /etc/autofs.conf' do
      expect(chef_run).not_to render_file('/etc/autofs.conf')
    end

    it 'manages /etc/default/autofs' do
      expect(chef_run).to create_template('/etc/default/autofs').with_mode('0644')

      expect(chef_run).to render_file('/etc/default/autofs')
                            .with_content(%r(MASTER_MAP_NAME=auto.master))
                            .with_content(%r(LDAP_URI="ldap://ldap01.example.com/ ldap://ldap02.example.com/"))
                            .with_content(%r(ENTRY_ATTRIBUTE="cn"))
      expect(chef_run).to_not render_file('/etc/default/autofs')
                                .with_content(%r(ENTRY_ATTRIBUTE="automountKey"))
    end

    it 'starts the autofs-service' do
      expect(chef_run).to start_service('autofs')
    end

    it 'does restart autofs-service on config-change' do
      c = chef_run.cookbook_file('/etc/init.d/autofs')
      expect(c).to notify('service[autofs]').to(:restart).delayed
    end
  end

  context 'with auth switched on' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['autofs']['ldap']['auth'] = true
      end.converge(described_recipe)
    end

    it 'manages /etc/autofs_ldap_auth.conf' do
      expect(chef_run).to create_template('/etc/autofs_ldap_auth.conf')
      .with_mode('0600')
      expect(chef_run).to render_file('/etc/autofs_ldap_auth.conf')
                            .with_content(/\s+authrequired="yes"/)
      expect(chef_run).to_not render_file('/etc/autofs_ldap_auth.conf')
                                .with_content(/\s+tlsrequired="yes"/)
    end
  end

  context 'with tls switched on' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['autofs']['ldap']['tls'] = true
      end.converge(described_recipe)
    end

    it 'manages /etc/autofs_ldap_auth.conf' do
      expect(chef_run).to render_file('/etc/autofs_ldap_auth.conf')
                            .with_content(/\s+tlsrequired="yes"/)
      expect(chef_run).to_not render_file('/etc/autofs_ldap_auth.conf')
                                .with_content(/\s+authrequired="yes"/)
    end
  end

  context 'on wheezy' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'debian', version: '7.11') do |node|
        node.default['sys']['autofs']['maps'] = {
          'map' => { }
        }
      end.converge(described_recipe)
    end

    it 'manages /etc/auto.master' do
      expect(chef_run).to create_template('/etc/auto.master').with_mode('0644')
      expect(chef_run).to render_file('/etc/auto.master').with_content('/map autofs.map')
      expect(chef_run).to render_file('/etc/auto.master').with_content('+auto.master')
      expect(chef_run).not_to render_file('/etc/auto.master').with_content('+dir:/etc/auto.master.d')
    end
  end
end
