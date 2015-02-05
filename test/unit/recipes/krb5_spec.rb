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
      chef_run.node.default.sys.krb5.realm = "example.com"
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

  context 'with keytab_config and distribution wallet' do

    before do
      chef_run.node.default['sys']['krb5']['distribution'] = "wallet"
      chef_run.node.default['sys']['krb5'][:'keytab_config'] = [
        { :keytab => "default" },
        { :keytab => "foo",
          :place => "/etc/bar.keytab",
          :mode => "0666",
          :owner => "foo",
          :group => "bar" },
        { :keytab => "not_there",
          :place => "/does/not/exist"}
      ]
      chef_run.node.automatic['domain'] = 'example.com'
      chef_run.node.automatic['fqdn'] = 'node.example.com'
      chef_run.node.default.sys.krb5.realm = "example.com"
      ktutil_command = "ktutil -k /etc/default.keytab list --keys | grep "
      ktutil_command += "-q default/node.example.com@EXAMPLE.COM"
      stub_command(ktutil_command).and_return(true)
      ktutil2_command = "ktutil -k /etc/bar.keytab list --keys | grep "
      ktutil2_command += "-q foo/node.example.com@EXAMPLE.COM"
      stub_command(ktutil2_command).and_return(true)
      ktutil3_command = "ktutil -k /does/not/exist list --keys | grep "
      ktutil3_command += "-q not_there/node.example.com@EXAMPLE.COM"
      stub_command(ktutil3_command).and_return(false)

      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:exists?).with('/etc/default.keytab').and_return(true)
      allow(File).to receive(:exists?).with('/etc/bar.keytab').and_return(true)
      allow(File).to receive(:exists?).with('/does/not/exist').and_return(false)
      chef_run.converge(described_recipe)
    end

    it 'installs wallet-client' do
      expect(chef_run).to install_package('wallet-client')
    end

    it 'sets default-mode for keytabs' do
      expect(chef_run).to create_file('/etc/default.keytab').with(
        :user => "root",
        :group => "root",
        :mode => "0600"
      )
    end

    it 'sets given mode for keytabs' do
      expect(chef_run).to create_file('/etc/bar.keytab').with(
        :user => "foo",
        :group => "bar",
        :mode => "0666"
      )
    end

    it 'does not create keytab-files' do
      expect(chef_run).not_to create_file("/does/not/exist")
    end

    it 'does deploy missing keytabs' do
      expect(chef_run).to run_bash('deploy not_there/node.example.com@EXAMPLE.COM')
    end

    it 'does not deploy existing keytabs' do
      expect(chef_run).not_to run_bash('deploy default/node.example.com@EXAMPLE.COM')
      expect(chef_run).not_to run_bash('deploy foo/node.example.com@EXAMPLE.COM')
    end
  end
end
