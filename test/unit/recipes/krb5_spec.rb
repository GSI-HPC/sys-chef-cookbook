require 'chefspec'

describe 'sys::krb5' do

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.krb5 is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with basic attributes' do

    before do
      chef_run.node.default['sys']['krb5']['realm'] = "example.com"
      chef_run.node.default['sys']['krb5']['admin_server'] = "master.example.com"
      chef_run.node.default['sys']['krb5']['master'] = "master.example.com"
      chef_run.node.default['sys']['krb5']['slave'] = "slave.example.com"
      chef_run.node.automatic['domain'] = 'example.com'
      chef_run.converge(described_recipe)
    end

    it 'installs packages' do
      expect(chef_run).to install_package('heimdal-clients')
      expect(chef_run).to install_package('libpam-heimdal')
      expect(chef_run).to install_package('heimdal-kcm')
      expect(chef_run).to install_package('heimdal-docs')
      expect(chef_run).to install_package('libsasl2-modules-gssapi-heimdal')
      expect(chef_run).to install_package('kstart')
    end

    it 'manages /etc/krb5.conf' do
      expect(chef_run).to create_template('/etc/krb5.conf').with_mode('0644')
      expect(chef_run).to create_template('/etc/krb5.conf').with(
        :variables => {
          :realm => "EXAMPLE.COM",
          :admin_server => "master.example.com",
          :servers => [ 'master.example.com', 'slave.example.com'],
          :domain => "example.com",
          :wallet_server => nil,
          :use_pkinit => nil
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

    before do
      chef_run.node.default.sys.krb5.realm = "example.com"
      chef_run.node.default['sys']['krb5']['admin_server'] = "master.example.com"
      chef_run.node.default['sys']['krb5']['master'] = "master.example.com"
      chef_run.node.default['sys']['krb5']['slave'] = "slave.example.com"
      chef_run.node.default['sys']['krb5']['use_pkinit'] = true
      chef_run.node.default['sys']['krb5']['wallet_server'] = "wallet.example.com"
      chef_run.node.automatic['domain'] = 'example.com'
      chef_run.converge(described_recipe)
      stub_command('File.exists?("/etc/krb5.keytab"').and_return(true)
    end

    it "configures pkinit and wallet" do
      expect(chef_run).to create_template('/etc/krb5.conf').with(
        :variables => {
          :realm => "EXAMPLE.COM",
          :admin_server => "master.example.com",
          :servers => [ 'master.example.com', 'slave.example.com'],
          :domain => "example.com",
          :wallet_server => "wallet.example.com",
          :use_pkinit => true
        }
      )
      expect(chef_run).to render_file("/etc/krb5.conf").with_content("\tuse_pkinit = true")
      expect(chef_run).to render_file('/etc/krb5.conf').with_content("\t\twallet_server = wallet.example.com")

    end
  end

  context 'sys_wallet' do
    let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['sys_wallet'])}

    before do
      chef_run.node.default['sys']['krb5']['dummy'] = true
      chef_run.node.automatic['fqdn'] = 'node.example.com'
      chef_run.converge(described_recipe)
    end

    it 'deploys keytab' do
      expect(chef_run).to deploy_sys_wallet('host/node.example.com')
    end
  end
end
