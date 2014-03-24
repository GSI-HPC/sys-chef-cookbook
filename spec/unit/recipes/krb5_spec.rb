require 'chefspec'

describe 'sys::krb5' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  context 'node.sys.krb5 is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with basic attributes' do
    before do
      master = 'master.example.com'
      slave = 'slave.example.com'
      fqdn = 'node.example.com'
      chef_run.node.default['sys']['krb5']['realm'] = 'example.com'
      chef_run.node.default['sys']['krb5']['master'] = master
      chef_run.node.default['sys']['krb5']['admin_server'] = master
      chef_run.node.default['sys']['krb5']['slave'] = slave
      chef_run.node.default['sys']['krb5']['distribution'] = 'wallet'
      chef_run.node.automatic['fqdn'] = fqdn
      chef_run.node.automatic['domain'] = "example.com"
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/krb5.conf' do
      expect(chef_run).to create_template('/etc/krb5.conf').with_mode('0644')
    end

    it 'installs packages' do
      expect(chef_run).to install_package('heimdal-clients')
      expect(chef_run).to install_package('libpam-heimdal')
      expect(chef_run).to install_package('heimdal-kcm')
      expect(chef_run).to install_package('heimdal-docs')
      expect(chef_run).to install_package('libsasl2-modules-gssapi-heimdal')
    end

    it 'defines attributes in /etc/krb5.conf' do
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

      test = chef_run.find_resource(:template, '/etc/krb5.conf')
      expect(ChefSpec::Renderer.new(chef_run, test).content).to_not include("try_pkinit =")
      expect(ChefSpec::Renderer.new(chef_run, test).content).to_not include("wallet_server =")
      expect(chef_run).to render_file('/etc/krb5.conf').with_content(
        "\texample.com = EXAMPLE.COM\n" +
          "\t.example.com = EXAMPLE.COM"
      )

      expect(chef_run).to render_file('/etc/krb5.conf').with_content(
        "\t\tkdc = master.example.com\n" +
          "\t\tkdc = slave.example.com"
      )
    end
  end

  context 'with wallet and pkinit attributes' do
    before do
      master = 'master.example.com'
      slave = 'slave.example.com'
      fqdn = 'node.example.com'
      chef_run.node.default['sys']['krb5']['realm'] = 'example.com'
      chef_run.node.default['sys']['krb5']['master'] = master
      chef_run.node.default['sys']['krb5']['admin_server'] = master
      chef_run.node.default['sys']['krb5']['slave'] = slave
      chef_run.node.default['sys']['krb5']['wallet_server'] = 'wallet.example.com'
      chef_run.node.default['sys']['krb5']['distribution'] = 'wallet'
      chef_run.node.default['sys']['krb5']['use_pkinit'] = true
      chef_run.node.automatic['fqdn'] = fqdn
      chef_run.node.automatic['domain'] = "example.com"
      chef_run.converge(described_recipe)
    end

    it "configures pkinit and wallet" do
      expect(chef_run).to render_file('/etc/krb5.conf').with_content(
        "\tuse_pkinit = true"
      )

      expect(chef_run).to render_file('/etc/krb5.conf').with_content(
        "\t\twallet_server = wallet.example.com"
      )
    end
  end
end
