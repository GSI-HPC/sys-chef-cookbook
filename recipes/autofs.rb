# coding: utf-8
#
# Cookbook Name:: sys
# Recipe:: autofs
#
# Copyright 2013 -2018 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
# Authors:
#  Victor Penso      2013 - 2015
#  Christopher Huhn  2013 - 2018
#  Matthias Pausch   2013 - 2017
#  Bastian Neuburger 2015
#  Dennis Klein      2015
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

return if node['sys']['autofs']['maps'].empty?

package 'autofs'
package 'autofs-ldap'

sys_wallet "autofsclient/#{node['fqdn']}" do
  place '/etc/autofs.keytab'
end

template '/etc/autofs_ldap_auth.conf' do
  source 'etc_autofs_ldap_auth.conf.erb'
  mode '0600'
  variables({
    :tls  => node['sys']['autofs']['ldap']['tls'],
    :auth => node['sys']['autofs']['ldap']['auth']
  })
  notifies :restart, 'service[autofs]'
end

config = {
  :uris       => node['sys']['autofs']['ldap']['servers'],
  :searchbase => node['sys']['autofs']['ldap']['searchbase'],
  :schema     => node['sys']['autofs']['ldap']['schema'],
  :browsemode => node['sys']['autofs']['browsemode'],
  :logging    => node['sys']['autofs']['logging']
}

if node['platform_version'].to_i >= 9
  template '/etc/autofs.conf' do
    source 'etc_autofs.conf.erb'
    mode '0644'
    variables(config)
    notifies :restart, 'service[autofs]'
  end
else
  template '/etc/default/autofs' do
    source 'etc_default_autofs.erb'
    mode '0644'
    variables(config)
    notifies :restart, 'service[autofs]'
  end
end

sys_systemd_unit 'autofs.service' do
  config({
    'Unit' => {
      'Description' => 'Automounts filesystems on demand',
      'After' => 'sssd.service network-online.target remote-fs.target'\
        'k5start-autofs.service',
      'BindsTo' => 'k5start-autofs.service',
      'Requires' => 'network-online.target',
      'Before' => 'graphical.target',
    },
    'Service' => {
      'Type' => 'forking',
      'PIDFile' => '/var/run/autofs.pid',
      'EnvironmentFile' => '-/etc/default/autofs',
      'ExecStart' => '/usr/sbin/automount $OPTIONS'\
        ' --pid-file /run/autofs.pid',
      'ExecReload' => '/bin/kill -HUP $MAINPID',
      'TimeoutSec' => '180',
    },
    'Install' => {
      'WantedBy' => 'gsi-remote.target',
    }
  })
  notifies :restart, 'service[autofs]'
end

sys_systemd_unit 'k5start-autofs.service' do
  config({
    'Unit' => {
      'Description' => 'Maintain Ticket-Cache for autofs',
      'Documentation' => 'man:k5start(1) man:autofs(8)',
      'After' => 'network-online.target',
      'Requires' => 'network-online.target',
      'Before' => 'autofs.service',
    },
    'Service' => {
      'Type' => 'forking',
      'ExecStart' => '/usr/bin/k5start -b -L -F -f /etc/autofs.keytab'\
        ' -K 60 -k /tmp/krb5cc_autofs -U -x',
      'Restart' => 'always',
      'RestartSec' => '5',
    },
    'Install' => {
      'WantedBy' => 'gsi-remote.target',
    }
  })
  notifies :restart, 'service[k5start-autofs]'
end

service 'k5start-autofs' do
  supports :restart => true, :reload => true
  action [:enable, :start]
end

service 'autofs' do
  supports :restart => true, :reload => true
  action [:enable, :start]
end
