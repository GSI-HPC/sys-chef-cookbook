require 'chefspec'

describe 'sys::autofs' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

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
      chef_run.converge(described_recipe)
    end

    it 'install autofs, autofs-ldap and kstart' do
      expect(chef_run).to install_package('autofs')
      expect(chef_run).to install_package('autofs-ldap')
      expect(chef_run).to install_package('kstart')
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
  end
end
