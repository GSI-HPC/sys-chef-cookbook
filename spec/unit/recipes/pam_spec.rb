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
      chef_run.node.default['sys']['pam']['limits'] = "limit_1\nlimit_2\nlimit_3"
      chef_run.node.default['sys']['pam']['group'] = [ 'group_1', 'group_2', 'group_3' ]
      chef_run.node.default['sys']['pamd']['common-test'] = "module1\nmodule2"
      chef_run.node.automatic['fqdn'] = fqdn
      chef_run.node.automatic['domain'] = "example.com"
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/security/access.conf' do
      expect(chef_run).to create_template('/etc/security/access.conf').with_mode('0600')
    end

    it 'manages /etc/pam.d/sshd' do
      expect(chef_run).to create_template('/etc/pam.d/sshd').with_mode('0644')
    end

    it 'manages /etc/pam.d/login' do
      expect(chef_run).to create_template('/etc/pam.d/login').with_mode('0644')
    end

    it 'manages /etc/security/limits.conf' do
      expect(chef_run).to create_template('/etc/security/limits.conf').with_mode('0644')
    end

    it 'manages /etc/security/group.conf' do
      expect(chef_run).to create_template('/etc/security/group.conf').with_mode('0644')
    end

    it 'manages /etc/pam.d/common-test' do
      expect(chef_run).to create_template('/etc/pam.d/common-test').with_mode('0644')
    end
  end
end
