describe 'sys::autofs' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.autofs.maps and node.sys.autofs.ldap is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with basic attributes' do
    before do
      chef_run.node.default['sys']['autofs']['maps'] = {
        "/mount/point" => { "path" => "config"}
      }
      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:exists?).with('/mount/point').and_return(false)
      chef_run.converge(described_recipe)
    end

    it 'installs autofs' do
      expect(chef_run).to install_package('autofs')
    end

    it 'manages /etc/auto.master' do
      expect(chef_run).to create_template('/etc/auto.master').with_mode("0644").with(
        :variables => {
          :maps => { "/mount/point" => { "path" => "config" }}
        }
      )
    end

    it 'creates necessary mount-points' do
      expect(chef_run).to create_directory('/mount/point')
    end

    it 'does not start the autofs-service' do
      expect(chef_run).to_not start_service('autofs')
    end
  end

  context 'with ldap attributes' do
    before do
      chef_run.node.automatic['fqdn'] = 'node.example.com'
      chef_run.node.automatic['sys']['autofs']['ldap']['servers'] = [
        'ldap01.example.com', 'ldap02.example.com'
      ]
      chef_run.node.default['sys']['autofs']['maps'] = {
        "/mount/point" => { "map" => "ldap:ou=autofs.mount,dc=example,dc=com"}
      }
      chef_run.node.default['sys']['autofs']['ldap'] = {:omg => :lol}
      chef_run.node.default['sys']['krb5']['realm'] = 'EXAMPLE.COM'
      chef_run.node.default['sys']['autofs']['ldap']['searchbase'] = 'dc=example,dc=com'
      chef_run.node.automatic['fqdn'] = 'node.example.com'
      chef_run.converge(described_recipe)
    end

    it 'installs autofs and autofs-ldap' do
      expect(chef_run).to install_package('autofs')
      expect(chef_run).to install_package('autofs-ldap')
    end

    it 'manages /etc/auto.master' do
      expect(chef_run).to create_template('/etc/auto.master').with_mode("0644").with(
        :variables => {
          :maps => { "/mount/point" => { "map" => "ldap:ou=autofs.mount,dc=example,dc=com" }}
        })

      expect(chef_run).to render_file('/etc/auto.master').with_content(
        "/mount/point ldap:ou=autofs.mount,dc=example,dc=com"
      )
    end

    it 'manages /etc/autofs_ldap_auth.conf' do
      expect(chef_run).to create_template('/etc/autofs_ldap_auth.conf').with_mode("0600").with(
        :variables => {
          :principal => 'node.example.com',
          :realm => 'EXAMPLE.COM'
        }
      )

      expect(chef_run).to render_file('/etc/autofs_ldap_auth.conf').with_content(
        "clientprinc=\"autofsclient/node.example.com@EXAMPLE.COM\""
      )
    end

    it 'manages /etc/default/autofs' do
      expect(chef_run).to create_template('/etc/default/autofs').with_mode("0644").with(
        :variables => {
          :uris => [ 'ldap01.example.com', 'ldap02.example.com' ],
          :searchbase => 'dc=example,dc=com',
          :browsemode => 'no'
        }
      )

      expect(chef_run).to render_file('/etc/default/autofs').with_content(
        "MASTER_MAP_NAME=/etc/auto.master"
      )

      expect(chef_run).to render_file('/etc/default/autofs').with_content(
        'LDAP_URI="ldap://ldap01.example.com/ ldap://ldap02.example.com/'
      )
    end

    it 'manages /etc/init.d/autofs' do
      expect(chef_run).to create_cookbook_file('/etc/init.d/autofs').with_mode("0755")
    end

    it 'not start the autofs-service' do
      expect(chef_run).to_not start_service('autofs')
    end

    it 'does reload autofs-service on config-change' do
      resource = chef_run.template('/etc/auto.master')
      expect(resource).to notify('service[autofs]').to(:reload).delayed
    end

    it 'does restart autofs-service on config-change' do
      a = chef_run.template('/etc/autofs_ldap_auth.conf')
      expect(a).to notify('service[autofs]').to(:restart).delayed
      b = chef_run.template('/etc/default/autofs')
      expect(b).to notify('service[autofs]').to(:restart).delayed
      c = chef_run.cookbook_file('/etc/init.d/autofs')
      expect(c).to notify('service[autofs]').to(:restart).delayed
    end
  end
end
