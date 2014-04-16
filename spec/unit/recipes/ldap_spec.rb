require 'chefspec'

describe 'sys::ldap' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  context 'node.sys.ldap is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    before do
      stub_command("test -e /etc/init.d/nscd").and_return(true)
      master = 'master.example.com'
      slave = 'slave.example.com'
      fqdn = 'node.example.com'
      chef_run.node.default['sys']['ldap']['master'] = master
      chef_run.node.default['sys']['ldap']['slave'] = slave
      chef_run.node.default['sys']['ldap']['searchbase'] = 'dc=example,dc=com'
      chef_run.node.default['sys']['ldap']['realm'] = 'EXAMPLE.COM'
      chef_run.node.default['sys']['ldap']['cacert'] = "/etc/ssl/ca.cert"
      chef_run.node.automatic['fqdn'] = fqdn
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/default/nslcd' do
      expect(chef_run).to create_template('/etc/default/nslcd').with_mode('0644')
    end

    it 'manages /etc/nslcd.conf' do
      expect(chef_run).to create_template('/etc/nslcd.conf').with_mode('0644')
    end

    it 'manages /etc/ldap/ldap.conf' do
      expect(chef_run).to create_template('/etc/ldap/ldap.conf').with_mode('0644')
    end

    it 'installs packages' do
      expect(chef_run).to install_package('nslcd')
      expect(chef_run).to install_package('kstart')
      expect(chef_run).to install_package('libpam-ldapd')
      expect(chef_run).to install_package('libnss-ldapd')
      expect(chef_run).to install_package('ldap-utils')
    end

    it 'defines k5start_principal in /etc/default/nslcd' do
      expect(chef_run).to create_template('/etc/default/nslcd')
      expect(chef_run).to render_file('/etc/default/nslcd').with_content(
        "K5START_PRINCIPAL='nslcd/node.example.com"
      )
    end

    it 'defines ldap-servers and auth-data in /etc/nslcd.conf' do
      uri_m = "URI ldap://master.example.com"
      uri_s = "URI ldap://slave.example.com"
      uris = uri_m + "\n" + uri_s
      authc = "sasl_authcid nslcd/node.example.com@EXAMPLE.COM"
      authz = "sasl_authzid u:nslcd/node.example.com"
      expect(chef_run).to create_template('/etc/nslcd.conf').with(
        :variables => {
          :servers => [ chef_run.node.sys.ldap.master, chef_run.node.sys.ldap.slave ],
          :searchbase => chef_run.node.sys.ldap.searchbase,
          :realm => chef_run.node.sys.ldap.realm.upcase
        }
      )
      expect(chef_run).to render_file('/etc/nslcd.conf').with_content(uris)
      expect(chef_run).to render_file('/etc/nslcd.conf').with_content(authc)
      expect(chef_run).to render_file('/etc/nslcd.conf').with_content(authz)
    end

    it 'defines ldap-servers in /etc/ldap/ldap.conf' do
      ldapservers = "URI ldap://master.example.com ldap://slave.example.com"
      cacert = "/etc/ssl/ca.cert"
      expect(chef_run).to create_template('/etc/ldap/ldap.conf').with(
        :variables => {
          :servers => [ chef_run.node.sys.ldap.master, chef_run.node.sys.ldap.slave ],
          :searchbase => chef_run.node.sys.ldap.searchbase,
          :realm => chef_run.node.sys.ldap.realm.upcase,
          :cacert => cacert
        }
      )
      expect(chef_run).to render_file('/etc/ldap/ldap.conf').with_content(ldapservers)
      expect(chef_run).to render_file('/etc/ldap/ldap.conf').with_content("TLS_CACERT " + cacert)
    end

    it 'stops and disables nscd' do
      expect(chef_run).to stop_service('nscd')
      expect(chef_run).to disable_service('nscd')
    end
  end
end
