#
# Cookbook:: sys
# Recipe:: ssh
#
# Copyright 2012-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn  <c.huhn@gsi.de>
#  Dennis Klein      <d.klein@gsi.de>
#  Matthias Pausch   <m.pausch@gsi.de>
#  Victor Penso      <v.penso@gsi.de>
#  Thomas Roth       <t.roth@gsi.de>
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

  #  different name for init file/systemd unit on centos:
  ssh_service = case node['platform_family']
                when 'rhel'
                  'sshd'
                else
                  'ssh'
                end

  service ssh_service do
    supports :reload => true
  end

  # overwrite the default configuration
  sshd_config.merge! node['sys']['sshd']['config']
  template '/etc/ssh/sshd_config' do
    source 'etc_ssh_sshd_config.erb'
    mode '0644'
    variables :config => sshd_config
    notifies :restart, "service[#{ssh_service}]"
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
