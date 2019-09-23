require 'spec_helper'

describe 'sys::ssh' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.ssh is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with basic attributes' do
    before do
      stub_command("grep -q -F \"BBB\" /home/jdoe/.ssh/authorized_keys")
        .and_return(0)
      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?).with('/home/jdoe').and_return(true)

      chef_run.node.default['sys']['sshd']['config'] = {
        'variable' => "value",
        'X11Forwarding' => "overwritten" }
      chef_run.node.default['sys']['ssh']['config'] = { "ssh" => "omg" }
      chef_run.node.default['sys']['ssh']['authorize'] = {
        'jdoe' => {
          keys:    [ "BBB" ],
          managed: true
        }
      }
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
        'UsePAM'        =>'yes',
        'ChallengeResponseAuthentication' => 'no',
        'PrintMotd'     => 'no',
        'AcceptEnv'     => 'LANG LC_*',
        'Subsystem'     => 'sftp /usr/lib/openssh/sftp-server',
        'HostKey' => %w[ /etc/ssh/ssh_host_rsa_key
                         /etc/ssh/ssh_host_ecdsa_key
                          /etc/ssh/ssh_host_ed25519_key],
        'AddressFamily' => 'inet',
        'variable'      => "value",
        'X11Forwarding' => "overwritten",
        'UseDNS'        => 'yes'
      }
      expect(chef_run).to create_template('/etc/ssh/sshd_config')
                           .with_mode('0644').with(
                             :variables => {
                               :config => sshd_config
                             }
                           )
      expect(chef_run).to render_file('/etc/ssh/sshd_config').with_content(
        "ChallengeResponseAuthentication no\nX11Forwarding overwritten"
      )
    end

    it 'manages ssh-user-config' do
      expect(chef_run).to create_directory("/home/jdoe/.ssh")

      # chefspec checks the resource name in create_file,
      #  not the actual file name ...
      expect(chef_run).to create_file('Deploying SSH keys for account '\
                                      'jdoe to /home/jdoe/.ssh/authorized_keys')
    end

  end
end
