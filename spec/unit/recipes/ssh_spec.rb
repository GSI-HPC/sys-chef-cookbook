describe 'sys::ssh' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  context 'node.sys.ssh is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with basic attributes' do
    before do
      stub_command("grep -q -F \"BBB\" /home/jdoe/.ssh/authorized_keys").and_return(0)
      fqdn = 'node.example.com'
      chef_run.node.default['sys']['sshd']['config'] = {
        'variable' => "value",
        'X11Forwarding' => "overwritten" }
      chef_run.node.default['sys']['ssh']['config'] = { "ssh" => "omg" }
      chef_run.node.default['sys']['ssh']['authorize'] = { 'jdoe' => {:keys => [ "BBB" ]} }
      chef_run.node.default['etc']['passwd']['jdoe']['keys'] = [ "AAA" ]
      chef_run.node.default['etc']['passwd']['jdoe']['uid'] = 1000
      chef_run.node.default['etc']['passwd']['jdoe']['gid'] = 1000
      chef_run.node.default['etc']['passwd']['jdoe']['dir'] = '/home/jdoe'
      chef_run.converge(described_recipe)
    end

    it 'installs openssh-server' do
      expect(chef_run).to install_package('openssh-server')
    end

    it 'manages /etc/ssh/sshd_config' do
      sshd_config = {
        "Port" => "22",
        "Protocol" => "2",
        "HostKey" => [
          "/etc/ssh/ssh_host_rsa_key",
          "/etc/ssh/ssh_host_dsa_key",
          "/etc/ssh/ssh_host_ecdsa_key"
        ],
        "UsePrivilegeSeparation" => "yes",
        "KeyRegenerationInterval" => "3600",
        "ServerKeyBits" => "768",
        "SyslogFacility" => "AUTH",
        "LogLevel" => "INFO",
        "LoginGraceTime" => "120",
        "PermitRootLogin" => "yes",
        "StrictModes" => "yes",
        "RSAAuthentication" => "yes",
        "PubkeyAuthentication" => "yes",
        "IgnoreRhosts" => "yes",
        "RhostsRSAAuthentication" => "no",
        "HostbasedAuthentication" => "no",
        "PermitEmptyPasswords" => "no",
        "ChallengeResponseAuthentication" => "no",
        "X11Forwarding" => "overwritten",
        "X11DisplayOffset" => "10",
        "PrintMotd" => "no",
        "PrintLastLog" => "yes",
        "TCPKeepAlive" => "yes",
        "AcceptEnv" => "LANG LC_*",
        "Subsystem" => "sftp /usr/lib/openssh/sftp-server",
        "UsePAM" => "yes",
        "variable" => "value"
      }
      expect(chef_run).to create_template('/etc/ssh/sshd_config').with_mode('0644').with(
        :variables => {
          :config => sshd_config
        }
      )

      expect(chef_run).to create_directory("/home/jdoe/.ssh")

      expect(chef_run).to create_file("/home/jdoe/.ssh/authorized_keys")

      expect(chef_run).to render_file('/etc/ssh/sshd_config').with_content(
        "ChallengeResponseAuthentication no\nX11Forwarding overwritten"
      )
    end
  end
end
