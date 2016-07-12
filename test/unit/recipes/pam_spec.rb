describe 'sys::pam' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

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

  context "with attributes for active pam-updates" do
    before do
      # krb5.keytab existance check turns on Kerberos support:
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/etc/krb5.keytab').and_return(true)

      chef_run.node.default['sys']['pamupdate'] = {
        "access" => {
          :Name => "access",
          :Default => "yes",
          :Priority => "256",
          :"Account-Type" => "Additional",
          :Account => "required			pam_access.so" },
        "group" => {
          :Name => "PAM group",
          :Default => "yes",
          :Priority => "256",
          :"Auth-Type" => "Additional",
          :Auth => "optional			pam_group.so" },
        "unix" => {
          :Name => "Unix authentication",
          :Default => "yes",
          :Priority => "256",
          :"Auth-Type" => "Primary",
          :Auth => "[success=end default=ignore]	pam_unix.so nullok_secure try_first_pass",
          :"Auth-Initial" => "[success=end default=ignore]	pam_unix.so nullok_secure",
          :"Account-Type" => "Primary",
          :Account => "[success=end new_authtok_reqd=done default=ignore]	pam_unix.so",
          :"Account-Initial" => "[success=end new_authtok_reqd=done default=ignore]	pam_unix.so",
          :"Session-Type" => "Additional",
          :Session => "required	pam_unix.so",
          :"Session-Initial" => "required	pam_unix.so",
          :"Password-Type" => "Primary",
          :Password => "[success=end default=ignore]	pam_unix.so obscure use_authtok try_first_pass sha512",
          :"Password-Initial" => "[success=end default=ignore]	pam_unix.so obscure sha512" },
        "krb5" => {
          :Name => "Kerberos authentication",
          :Default => "yes",
          :Priority => "704",
          :Conflicts => "krb5-openafs",
          :"Auth-Type" => "Primary",
          :Auth => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000 try_first_pass",
          :"Auth-Initial" => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000",
          :"Account-Type" => "Additional",
          :Account => "required			pam_krb5.so minimum_uid=1000",
          :"Password-Type" => "Primary",
          :Password => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000 try_first_pass use_authtok",
          :"Password-Initial" => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000",
          :"Session-Type" => "Additional",
          :Session => "optional			pam_krb5.so minimum_uid=1000" }}
      chef_run.converge(described_recipe)
    end

    it "should create /etc/pam.d/common-*" do
      expect(chef_run).to render_file('/etc/pam.d/common-account').with_content(
        "# /etc/pam.d/common-account
#
# DO NOT CHANGE THIS FILE MANUALLY!
#
# This file is managed by the Chef `sys` cookbook.

account\t\t[success=1 new_authtok_reqd=done default=ignore]\tpam_unix.so
account\t\trequisite\t\tpam_deny.so
account\t\trequired\t\tpam_permit.so
account\t\trequired\t\t\tpam_krb5.so minimum_uid=1000
account\t\trequired\t\t\tpam_access.so"
      )

      expect(chef_run).to render_file('/etc/pam.d/common-auth').with_content(
        "# /etc/pam.d/common-auth
#
# DO NOT CHANGE THIS FILE MANUALLY!
#
# This file is managed by the Chef `sys` cookbook.

auth\t\t[success=2 default=ignore]\tpam_krb5.so minimum_uid=1000
auth\t\t[success=1 default=ignore]\tpam_unix.so nullok_secure try_first_pass
auth\t\trequisite\t\tpam_deny.so
auth\t\trequired\t\tpam_permit.so
auth\t\toptional\t\t\tpam_group.so"
      )

      expect(chef_run).to render_file('/etc/pam.d/common-password').with_content(
        "# /etc/pam.d/common-password
#
# DO NOT CHANGE THIS FILE MANUALLY!
#
# This file is managed by the Chef `sys` cookbook.

password\t\t[success=2 default=ignore]\tpam_krb5.so minimum_uid=1000
password\t\t[success=1 default=ignore]\tpam_unix.so obscure use_authtok try_first_pass sha512
password\t\trequisite\t\tpam_deny.so
password\t\trequired\t\tpam_permit.so"
      )

      expect(chef_run).to render_file('/etc/pam.d/common-session').with_content(
        "# /etc/pam.d/common-session
#
# DO NOT CHANGE THIS FILE MANUALLY!
#
# This file is managed by the Chef `sys` cookbook.

session\t\t[default=1]\t\tpam_permit.so
session\t\trequisite\t\tpam_deny.so
session\t\trequired\t\tpam_permit.so
session\t\toptional\t\t\tpam_krb5.so minimum_uid=1000
session\t\trequired\tpam_unix.so"
      )
    end

    it "should not configure Kerberos if /etc/krb5.keytab is not present" do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("/etc/krb5.keytab").and_return(false)
      chef_run.converge(described_recipe)
      expect(chef_run).to create_template('/etc/pam.d/common-auth')
      expect(chef_run).to render_file('/etc/pam.d/common-auth').with_content(
        "# /etc/pam.d/common-auth
#
# DO NOT CHANGE THIS FILE MANUALLY!
#
# This file is managed by the Chef `sys` cookbook.

auth\t\t[success=1 default=ignore]\tpam_unix.so nullok_secure
auth\t\trequisite\t\tpam_deny.so
auth\t\trequired\t\tpam_permit.so
auth\t\toptional\t\t\tpam_group.so"
      )
    end
  end

  context "with attributes for inactive pam-updates" do
    before do
      chef_run.node.default['sys']['pamupdate'] = {
        "access" => {
          :Name => "access",
          :Default => "anything but yes",
          :Priority => "256",
          :"Account-Type" => "Additional",
          Account: "required			pam_access.so" },
        "group" => {
          :Name => "PAM group",
          :Default => "no",
          :Priority => "256",
          :"Auth-Type" => "Additional",
          :Auth => "optional			pam_group.so" },
        "unix" => {
          :Name => "Unix authentication",
          :Default => "false",
          :Priority => "256",
          :"Auth-Type" => "Primary",
          :Auth => "[success=end default=ignore]	pam_unix.so nullok_secure try_first_pass",
          :"Auth-Initial" => "[success=end default=ignore]	pam_unix.so nullok_secure",
          :"Account-Type" => "Primary",
          :Account => "[success=end new_authtok_reqd=done default=ignore]	pam_unix.so",
          :"Account-Initial" => "[success=end new_authtok_reqd=done default=ignore]	pam_unix.so",
          :"Session-Type" => "Additional",
          :Session => "required	pam_unix.so",
          :"Session-Initial" => "required	pam_unix.so",
          :"Password-Type" => "Primary",
          :Password => "[success=end default=ignore]	pam_unix.so obscure use_authtok try_first_pass sha512",
          :"Password-Initial" => "[success=end default=ignore]	pam_unix.so obscure sha512" },
        "krb5" => {
          :Name => "Kerberos authentication",
          :Default => "och noe",
          :Priority => "704",
          :Conflicts => "krb5-openafs",
          :"Auth-Type" => "Primary",
          :Auth => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000 try_first_pass",
          :"Auth-Initial" => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000",
          :"Account-Type" => "Additional",
          :Account => "required			pam_krb5.so minimum_uid=1000 ignore_k5login",
          :"Password-Type" => "Primary",
          :Password => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000 try_first_pass use_authtok",
          :"Password-Initial" => "[success=end default=ignore]	pam_krb5.so minimum_uid=1000",
          :"Session-Type" => "Additional",
          :Session => "optional			pam_krb5.so minimum_uid=1000" }}
      chef_run.converge(described_recipe)
    end

    it "should do nothing" do
      expect(chef_run).to_not create_template('/etc/pam.d/common-auth')
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end
end
