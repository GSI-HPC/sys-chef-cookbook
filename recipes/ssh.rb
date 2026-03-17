#
# Cookbook:: sys
# Recipe:: ssh
#
# Copyright 2012-2026 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn  <c.huhn@gsi.de>
#  Dennis Klein      <d.klein@gsi.de>
#  Matthias Pausch   <m.pausch@gsi.de>
#  Victor Penso      <v.penso@gsi.de>
#  Thomas Roth       <t.roth@gsi.de>
#  Karim Elaammari   <k.elaammari@gsi.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# default SSH
sshd_config = {}
sshd_config['UsePAM'] = 'yes'
sshd_config['ChallengeResponseAuthentication'] = 'no'
sshd_config['X11Forwarding'] = 'yes'
sshd_config['PrintMotd'] = 'no'
sshd_config['AcceptEnv'] = 'LANG LC_*'
sshd_config['Subsystem'] = 'sftp /usr/lib/openssh/sftp-server'
sshd_config['HostKey'] = ['/etc/ssh/ssh_host_rsa_key', '/etc/ssh/ssh_host_ecdsa_key']
sshd_config['UseDNS'] = 'yes'                             if debian_version >= 9
sshd_config['HostKey'] << '/etc/ssh/ssh_host_ed25519_key' if debian_version >= 8
sshd_config['PermitRootLogin'] = 'without-password'       if debian_version < 9
sshd_config['AddressFamily'] = 'inet'

# only if SSH daemon configuration is defined
unless node['sys']['sshd']['config'].empty?
  package 'openssh-server'
  service 'ssh' do
    supports :reload => true
  end

  # deploy ssh host keys
  if  node['sys']['sshd']['host_keys_vault'] &&
      node['sys']['sshd']['host_keys_item']
    begin
      host_keys = []

      chef_vault_item(
        node['sys']['sshd']['host_keys_vault'],
        node['sys']['sshd']['host_keys_item']
      )['keys'].each do |key_name, key|

        # calculate the public key
        # also checks the validity of the private key:
        ssh_keygen = Mixlib::ShellOut.new(
          'ssh-keygen -y -f /dev/stdin',
          input: key
        )
        ssh_keygen.run_command

        if ssh_keygen.error?
          Chef::Log.warn(
            format("Can't generate public key for %s in vault item %s::%s: %s",
                   key_name,
                   node['sys']['sshd']['host_keys_vault'],
                   node['sys']['sshd']['host_keys_item'],
                   ssh_keygen.stderr
                  )
          )
          next
        end

        public_key = ssh_keygen.stdout
        # check whether the pubkey has the right form:
        if public_key !~ /^(ssh-)?#{key_name}[ -]/
          Chef::Log.warn(
            format("Public key for %s in vault item %s::%s looks incorrect: %s",
                   key_name,
                   node['sys']['sshd']['host_keys_vault'],
                   node['sys']['sshd']['host_keys_item'],
                   public_key
                  )
          )
          next
        end

        key_filename = "/etc/ssh/ssh_host_#{key_name}_key"

        # the private key
        file key_filename do
          content key
          owner 'root'
          group 'root'
          mode '0600'
          sensitive true
          notifies :restart, 'service[ssh]'
        end

        # the public key
        file "#{key_filename}.pub" do
          content public_key
          owner 'root'
          group 'root'
          mode '0644'
        end

        host_keys << key_filename
      end

      sshd_config['HostKey'] = host_keys unless host_keys.empty?
    rescue ChefVault::Exceptions::ItemNotFound
      Chef::Log.warn(
        format("No host keys deployed: Vault item %s::%s not found",
               node['sys']['sshd']['host_keys_vault'],
               node['sys']['sshd']['host_keys_item'])
      )
    end
  end

  # overwrite the default configuration
  sshd_config.merge! node['sys']['sshd']['config']
  template '/etc/ssh/sshd_config' do
    source 'etc_ssh_sshd_config.erb'
    mode '0644'
    variables :config => sshd_config
    notifies :restart, 'service[ssh]'
  end
end

unless node['sys']['ssh']['ssh_config'].empty? # ~FC023
  template '/etc/ssh/ssh_config' do
    source 'etc_ssh_ssh_config.erb'
    mode '0644'
    variables :config => node['sys']['ssh']['ssh_config']
  end
end

unless node['sys']['ssh']['authorize'].empty?
  node['sys']['ssh']['authorize'].each do |account,params|
    sys_ssh_authorize account do
      keys params[:keys]
      managed params[:managed] if params.has_key? :managed
    end
  end
end

unless node['sys']['ssh']['config'].empty?
  node['sys']['ssh']['config'].each do |account,params|
    sys_ssh_config account do
      config params
    end
  end
end

if node['sys']['ssh']['known_hosts']
  template '/etc/ssh/ssh_known_hosts' do
    source 'etc_ssh_known_hosts.erb'
    mode 0o0644
    variables(
      hosts: node['sys']['ssh']['known_hosts']
    )
  end
end
