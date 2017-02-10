require 'chefspec'

describe 'sys::krb5' do

  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.krb5 is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with basic attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['krb5']['realm'] = "example.com"
        node.default['sys']['krb5']['admin_server'] = "master.example.com"
        node.default['sys']['krb5']['master'] = "master.example.com"
        node.default['sys']['krb5']['slave'] = "slave.example.com"
        node.automatic['domain'] = 'example.com'
        node.automatic['fqdn'] = 'node.example.com'
      end.converge(described_recipe)
    end

    it 'installs packages' do
      expect(chef_run).to install_package('heimdal-clients')
      expect(chef_run).to install_package('libpam-heimdal')
      expect(chef_run).to install_package('heimdal-kcm')
      expect(chef_run).to install_package('heimdal-docs')
      expect(chef_run).to install_package('libsasl2-modules-gssapi-heimdal')
      expect(chef_run).to install_package('kstart')
      expect(chef_run).to install_package('wallet-client')
    end

    it 'manages /etc/krb5.conf' do
      expect(chef_run).to create_template('/etc/krb5.conf').with_mode('0644')
      expect(chef_run).to create_template('/etc/krb5.conf').with(
        :variables => {
          :realm => "EXAMPLE.COM",
          :admin_server => "master.example.com",
          :servers => [ 'master.example.com', 'slave.example.com'],
          :domain => "example.com",
          :realms => [],
          :wallet_server => nil,
          :use_pkinit => nil,
          :libdefaults => nil
        }
      )
      expect(chef_run).to render_file("/etc/krb5.conf").with_content(
        "\t\tkdc = master.example.com\n\t\tkdc = slave.example.com"
      )
      expect(chef_run).to render_file('/etc/krb5.conf').with_content(
        "\texample.com = EXAMPLE.COM\n\t.example.com = EXAMPLE.COM"
      )
    end
  end

  context 'with wallet and pkinit attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default.sys.krb5.realm = "example.com"
        node.default['sys']['krb5']['admin_server'] = "master.example.com"
        node.default['sys']['krb5']['master'] = "master.example.com"
        node.default['sys']['krb5']['slave'] = "slave.example.com"
        node.default['sys']['krb5']['use_pkinit'] = true
        node.default['sys']['krb5']['wallet_server'] = "wallet.example.com"
        node.automatic['domain'] = 'example.com'
        node.automatic['fqdn'] = 'node.example.com'
      end.converge(described_recipe)
    end

    it "configures pkinit and wallet" do
      expect(chef_run).to create_template('/etc/krb5.conf').with(
        :variables => {
          :realm => "EXAMPLE.COM",
          :admin_server => "master.example.com",
          :servers => [ 'master.example.com', 'slave.example.com'],
          :domain => "example.com",
          :wallet_server => "wallet.example.com",
          :realms => [],
          :libdefaults => nil,
          :use_pkinit => true
        }
      )
      expect(chef_run).to render_file("/etc/krb5.conf").with_content("\tuse_pkinit = true")
      expect(chef_run).to render_file('/etc/krb5.conf').with_content("\t\twallet_server = wallet.example.com")
    end
  end

  context 'sys_wallet' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['krb5']['realm'] = 'dummy'
        node.automatic['fqdn'] = 'node.example.com'
      end.converge(described_recipe)
    end

    it 'deploys keytab' do
      chef_run.node.automatic['fqdn'] = 'node.example.com'
      chef_run.converge(described_recipe)
      expect(chef_run).to deploy_sys_wallet('host/node.example.com')
    end
  end

  context 'sys_harry' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['krb5']['krb5.conf'] = {
          :realms => {
            'EXAMPLE.COM' => {
              'kdc' => [
                'kdc1.example.com',
                'kdc2.example.com'
              ],
              'admin_server' => 'kdc1.example.com',
            }
          },
          :appdefaults => {
            'default_realm' => 'EXAMPLE.COM',
            'wallet' => {
              'wallet_port' => '4373',
              'wallet_server' => 'wallet.example.com'
            }
          }
        }
      end.converge(described_recipe)
    end

    it 'deploys krb5.conf with two sections' do
      config = ''
      config << "[realms]\n"
      config << "        EXAMPLE.COM = {\n"
      config << "                kdc          = kdc1.example.com\n"
      config << "                kdc          = kdc2.example.com\n"
      config << "                admin_server = kdc1.example.com\n"
      config << "        }\n"
      config << "\n"
      config << "[appdefaults]\n"
      config << "        default_realm = EXAMPLE.COM\n"
      config << "        wallet = {\n"
      config << "                wallet_port   = 4373\n"
      config << "                wallet_server = wallet.example.com\n"
      config << "        }\n"
      expect(chef_run).to create_template('/etc/krb5.conf').with_mode('0644')
      expect(chef_run).to render_file("/etc/krb5.conf").with_content(config)
    end
  end
end
