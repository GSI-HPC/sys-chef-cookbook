describe 'sys::ldap' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  context 'node.sys.ldap is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    before do
      stub_command("test -e /etc/init.d/nscd").and_return(true)
      ldap01 = 'ldap01.example.com'
      ldap02 = 'ldap02.example.com'
      fqdn = 'node.example.com'
      chef_run.node.default['sys']['ldap']['servers'] = [ ldap01, ldap02 ]
      chef_run.node.default['sys']['ldap']['searchbase'] = 'dc=example,dc=com'
      chef_run.node.default['sys']['ldap']['realm'] = 'EXAMPLE.COM'
      chef_run.node.default['sys']['ldap']['cacert'] = "/etc/ssl/ca.cert"
      chef_run.node.default['sys']['ldap']['nss_initgroups_ignoreusers'] = ['user1', 'user2']
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
      uri_m = "URI ldap://ldap01.example.com"
      uri_s = "URI ldap://ldap02.example.com"
      uris = uri_m + "\n" + uri_s
      authc = "sasl_authcid nslcd/node.example.com@EXAMPLE.COM"
      authz = "sasl_authzid u:nslcd/node.example.com"
      nss_ignore = "nss_initgroups_ignoreusers user1, user2"
      expect(chef_run).to create_template('/etc/nslcd.conf').with(
        :variables => {
          :servers => chef_run.node.sys.ldap.servers,
          :searchbase => chef_run.node.sys.ldap.searchbase,
          :realm => chef_run.node.sys.ldap.realm.upcase,
          :nslcd => nil,
          :nss_initgroups_ignoreusers => chef_run.node.sys.ldap.nss_initgroups_ignoreusers
        }
      )
      expect(chef_run).to render_file('/etc/nslcd.conf').with_content(uris)
      expect(chef_run).to render_file('/etc/nslcd.conf').with_content(authc)
      expect(chef_run).to render_file('/etc/nslcd.conf').with_content(authz)
      expect(chef_run).to render_file('/etc/nslcd.conf').with_content(nss_ignore)
    end

    it 'defines ldap-servers in /etc/ldap/ldap.conf' do
      ldapservers = "URI ldap://ldap01.example.com ldap://ldap02.example.com"
      cacert = "/etc/ssl/ca.cert"
      expect(chef_run).to create_template('/etc/ldap/ldap.conf').with(
        :variables => {
          :servers => chef_run.node.sys.ldap.servers,
          :searchbase => chef_run.node.sys.ldap.searchbase,
          :realm => chef_run.node.sys.ldap.realm.upcase,
          :cacert => cacert
        }
      )
      expect(chef_run).to render_file('/etc/ldap/ldap.conf').with_content(ldapservers)
      expect(chef_run).to render_file('/etc/ldap/ldap.conf').with_content("TLS_CACERT " + cacert)
    end

    it 'updates the init-file of nslcd' do
      expect(chef_run).to render_file('/etc/init.d/nslcd')
    end

    it 'updates the starting point of nslcd' do
      expect(chef_run).to_not run_execute('insserv /etc/init.d/nslcd')
    end

    it 'deploys a keytab for nslcd' do
      expect(chef_run).to deploy_sys_wallet('nslcd/node.example.com')
    end

    it 'sends notifications' do
      etc_nslcd_default = chef_run.template('/etc/default/nslcd')
      expect(etc_nslcd_default).to notify('service[nslcd]').to(:restart).delayed

      etc_nslcd_conf = chef_run.template('/etc/nslcd.conf')
      expect(etc_nslcd_conf).to notify('service[nslcd]').to(:restart).delayed

      etc_init_d_nslcd = chef_run.cookbook_file('/etc/init.d/nslcd')
      expect(etc_init_d_nslcd).to notify('execute[update-run-levels]').to(:run).immediately
    end

    it 'starts and enables nslcd' do
      expect(chef_run).to start_service('nslcd')
      expect(chef_run).to enable_service('nslcd')
    end
  end
end
