# coding: utf-8
#
# Cookbook Name:: sys
# Recipe:: autofs
#
# Copyright 2013 -2018 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
# Authors:
#  Victor Penso      2013 - 2015
#  Christopher Huhn  2013 - 2018
#  Matthias Pausch   2013 - 2019
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

return if node['sys']['autofs'].empty?

config = {
  :browsemode => node['sys']['autofs']['browsemode'] || 'no',
  :logging    => node['sys']['autofs']['logging'] || 'none'
}

package 'autofs'

# auto.master is available via ldap.  However, there is no convenient
# possibility to filter mountpoints.  That may result in many unwanted
# or unused mountpoints configured for the system.  Since nsswitch is
# configured to first query files, then ldap, it is possible to
# provide a local auto.master with fewer entries.  A local auto.master
# may list autofs-maps in other files, or in ldap.
# Example:
# ldap contains maps for /a, /b and /c, but only /b and /c are wanted
# on a system, where /c should not be read from ldap, but from a local
# file.
# The following steps achieve this configuration.
# Set 'automount: files ldap' in /etc/nsswitch.conf.
# Configure ldap, and create /etc/auto.master containing:
# /b autofs.b
# /c autofs.c
# Also create /etc/autofs.c on the system.
# On autofs-lookup, auto.master from ldap is not considered, because
# /etc/auto.master is found first.  /etc/autofs.b does not exist, but
# it is found in ldap, so it is taken from ldap.  /c is found in
# /etc/autfs.c, so ldap will not be used to lookup /c.

if node['sys']['autofs']['ldap']
  package 'autofs-ldap'

  config = {
    :uris       => node['sys']['autofs']['ldap']['servers'],
    :searchbase => node['sys']['autofs']['ldap']['searchbase'],
    :schema     => node['sys']['autofs']['ldap']['schema'] || 'rfc2307bis',
  }

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
        'WantedBy' => 'default.target',
      }
    })
    notifies :restart, 'service[k5start-autofs]'
    only_if { node['platform_version'].to_i >= 9 }
  end

  service 'k5start-autofs' do
    supports :restart => true, :reload => true
    action [:enable, :start]
    only_if { node['platform_version'].to_i >= 9 }
  end

  cookbook_file "/etc/init.d/autofs" do
    source "etc_init.d_autofs"
    mode "0755"
    notifies :restart, 'service[autofs]'
  end

  # 'autmount: files' is assumed, if no entry is present in /etc/nsswitch.conf
  node['sys']['nsswitch'] << "\nautomount: files ldap\n"
end

if node['sys']['autofs']['maps']
  maps = []
  node['sys']['autofs']['maps'].each do |map, values|
    maps << {
      mointpoint: values['mountpoint'] || "/#{map}",
      mapname: values['mapname'] || "autofs.#{map}",
      options: values['options'] ? " #{values['options']}" : ''
    }
  end
  template '/etc/auto.master' do
    source 'etc_auto.master.erb'
    mode '0644'
    variables(
      :maps => maps
    )
    notifies :reload, 'service[autofs]'
  end

  mountpoints = node['sys']['autofs']['create_mountpoints'] || []
  node['sys']['autofs']['create_mountpoints'].each do |mp|
    directory mp do
      recursive true
      mode '0755'
      owner 'root'
      group 'root'
    end
  end
end

template '/etc/autofs.conf' do
  source 'etc_autofs.conf.erb'
  mode '0644'
  variables(config)
  notifies :restart, 'service[autofs]'
  only_if { node['platform_version'].to_i >= 9 }
end

template '/etc/default/autofs' do
  source 'etc_default_autofs.erb'
  mode '0644'
  variables(config)
  notifies :restart, 'service[autofs]'
  only_if { node['platform_version'].to_i < 9 }
end

sys_systemd_unit 'autofs.service' do
  cfg = {
    'Unit' => {
      'Description' => 'Automounts filesystems on demand',
      'After' => 'sssd.service network-online.target remote-fs.target'\
        'k5start-autofs.service',
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
      'WantedBy' => 'default.target',
    }
  }
  cfg['BindsTo'] = 'k5start-autofs.service' if node['sys']['autofs']['ldap']
  config(cfg)
  notifies :restart, 'service[autofs]'
  only_if { node['platform_version'].to_i >= 9 }
end

service 'autofs' do
  supports :restart => true, :reload => true
  action [:enable, :start]
end
