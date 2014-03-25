require 'chefspec'

describe 'sys::pam' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  context 'node.sys.pam is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with basic attributes' do
    before do
      fqdn = 'node.example.com'
      chef_run.node.default['sys']['pam']['rules'] = [ 'rule_1', 'rule_2', 'rule_3' ]
      chef_run.node.default['sys']['pam']['access'] = [ 'access_1', 'access_2', 'access_3' ]
      chef_run.node.default['sys']['pamd']['sshd'] = "sshd_1\nsshd_2\nsshd_3"
      chef_run.node.default['sys']['pamd']['login'] = "login_1\nlogin_2\nlogin_3"
      chef_run.node.default['sys']['pam']['limits'] = [ "limit_1", "limit_2", "limit_3" ]
      chef_run.node.default['sys']['pam']['group'] = [ Hash.new, Hash.new, Hash.new ]
      chef_run.node.default['sys']['pamd']['common-test'] = " \n module1\nmodule2"
      chef_run.node.automatic['fqdn'] = fqdn
      chef_run.node.automatic['domain'] = "example.com"
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/security/access.conf' do
      expect(chef_run).to create_template('/etc/security/access.conf').with_mode('0600').with(
        :variables => {
          :rules => [ 'access_1', 'access_2', 'access_3' ]
        }
      )

      expect(chef_run).to render_file('/etc/security/access.conf').with_content(
        "access_1\naccess_2\naccess_3"
      )
    end

    it 'manages /etc/pam.d/sshd' do
      expect(chef_run).to create_template('/etc/pam.d/sshd').with_mode('0644')
    end

    it 'manages /etc/pam.d/login' do
      expect(chef_run).to create_template('/etc/pam.d/login').with_mode('0644')
    end

    it 'manages /etc/security/limits.conf' do
      expect(chef_run).to create_template('/etc/security/limits.conf').with_mode('0644').with(
        :variables => {
          :rules => [ "limit_1", "limit_2", "limit_3" ]
        }
      )

      expect(chef_run).to render_file('/etc/security/limits.conf').with_content(
        "limit_1\nlimit_2\nlimit_3"
      )
    end

    it 'manages /etc/security/group.conf' do
      expect(chef_run).to create_template('/etc/security/group.conf').with_mode('0644').with(
        :variables => {
          :rules => [ {}, {}, {} ]
        }
      )

      expect(chef_run).to render_file('/etc/security/group.conf').with_content(
        "*;*;*;Al0000-2400;"
      )
    end

    it 'manages /etc/pam.d/common-test' do
      expect(chef_run).to create_template('/etc/pam.d/common-test').with_mode('0644').with(
        :variables => {
          :rules => "module1\nmodule2",
          :name => "common-test"
        }
      )

      expect(chef_run).to render_file('/etc/pam.d/common-test').with_content(
        "module1"
      )
    end
  end

  context "with attributes for /etc/security/group.conf" do
    before do
      chef_run.node.default['sys']['pam']['group'] = [
        { :srv => 'server',
          :tty => 'terminal',
          :usr => 'user',
          :time => '2000',
          :grp => 'group' }
      ]
      chef_run.converge(described_recipe)
    end

    it "create /etc/security/group.conf" do
      expect(chef_run).to create_template('/etc/security/group.conf')
      expect(chef_run).to render_file('/etc/security/group.conf').with_content(
        "server;terminal;user;2000;group"
      )
    end
  end
end
