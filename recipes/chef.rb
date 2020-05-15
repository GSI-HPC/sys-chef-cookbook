# -*- coding: utf-8 -*-
#
# Cookbook Name:: sys
# Recipe:: chef
#
# set's up the chef-client
#
# Copyright 2011-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn    <c.huhn@gsi.de>
#  Dennis Klein        <d.klein@gsi.de>
#  Ilona Neis          <i.neis@gsi.de>
#  Bastian Neuburger   <b.neuburger@gsi.de>
#  Matthias Pausch     <m.pausch@gsi.de>
#  Victor Penso        <v.penso@gsi.de>
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

server_url = node['sys']['chef']['server_url']

# fallback for figuring out the chef server url following the "old" conventions
#  introduced by the chef cookbook
begin
  if !server_url && node['chef']['server']['fqdn']
    server_url = if node['chef']['server']['ssl']
                   "https://#{node['chef']['server']['fqdn']}:443"
                 else
                   "http://#{node['chef']['server']['fqdn']}:4000"
                 end
  end
rescue ArgumentError => e
  Chef::Log.debug e
end

# configuring the chef client only makes sense if the server is defined:
unless server_url
  log 'no_chef_server' do
    message "No chef server defined. Please set node['sys']['chef']['server_url'] to point to your chef server"
    level :warn
  end
  return
end

# actually we don't neccessarily need the Ohai recipe
include_recipe 'sys::ohai'

template '/etc/default/chef-client' do
  source 'etc_default_chef_client.erb'
  owner 'root'
  group 'root'
  mode "0644"
  variables(
    :interval => node['sys']['chef']['interval'],
    :splay    => node['sys']['chef']['splay']
  )
  notifies :restart, "service[chef-client]"
end

package 'ruby-sysloglogger' if node['sys']['chef']['use_syslog']

directory '/etc/chef' do
  owner 'root'
  group node['sys']['chef']['group']
  mode  0o0750
end

# compile attributes for the client.rb template:
v              = node['sys']['chef'].to_hash
v[:server_url] = server_url
v[:opath]      = node['ohai']['plugin_path']
v[:odisable]   = node['ohai']['disabled_plugins']

template '/etc/chef/client.rb' do
  source 'etc_chef_client.rb.erb'
  owner 'root'
  group node['sys']['chef']['group']
  mode "0644"
  variables v

  notifies :restart, "service[chef-client]"
  ignore_failure true
end

# add log rotaion for chef client log:
template '/etc/logrotate.d/chef' do
  source 'etc_logrotate.d_chef.erb'
end

# Delete the validation credential if the machines
# has already registered with the server, unless
# the node is a server itself, since if this is the
# case, the validation key would be regenerated on
# each chef-server restart.
# For now we assume that the chef server does not run sys::chef
file node['sys']['chef']['validation_key'] do
  action :delete
  backup false
  only_if { ::File.exist? node['sys']['chef']['client_key'] }
end

# make the client key group-readable
#  (so its members can use 'knife .. -c /etc/chef/client.pem')
file node['sys']['chef']['client_key'] do
  group node['sys']['chef']['group']
  mode  '0640'
end

# Create a script in cron.hourly to make sure chef-client keeps running
if node['sys']['chef']['restart_via_cron'] # ~FC023
  template '/etc/cron.hourly/chef-client' do
    source 'etc_cron.hourly_chef-client.erb'
    mode   '0755'
    helpers(Sys::Helper)
  end
end

if node['sys']['chef']['init_style'] == 'systemd'
  # mimic the chef-client cookbook systemd unit:
  systemd_unit 'chef-client.service' do
    content(
      'Unit' => {
        'Description' => 'Chef Infra Client',
        'After' => 'network.target auditd.service',
      },
      'Service' => {
        'Type' => 'oneshot',
        'EnvironmentFile' => '/etc/default/chef-client',
        'ExecStart' => '/usr/bin/chef-client -c $CONFIG $OPTIONS',
        'ExecReload' => '/bin/kill -HUP $MAINPID',
        'SuccessExitStatus' => 3,
      },
      'Install' => { 'WantedBy' => 'multi-user.target' },
    )
    action :create
  end

  # mimic the chef-client cookbook systemd unit:
  systemd_unit 'chef-client.timer' do
    content(
      'Unit' => { 'Description' => 'chef-client periodic run' },
      'Install' => { 'WantedBy' => 'timers.target' },
      'Timer' => {
        'OnBootSec' => '1min',
        'OnUnitInactiveSec' => "#{node['sys']['chef']['interval']}sec",
        'RandomizedDelaySec' => "#{node['sys']['chef']['splay']}sec",
      }
    )
    action [:create, :enable, :start]
  end
else
  # Comments in systemctl-src say that update-rc.d does not provide
  # information wheter a service is enabled or not and always returns
  # false.  Work around that.
  actions = [:start]
  actions << :enable if Dir.glob('/etc/rc2.d/*chef-client*').empty?
  actions << :enable if Dir.glob('/etc/rc2.d/*chef-client*').empty?
end

service 'chef-client' do
  supports :restart => true, :status => true
  action actions
  ignore_failure true
end
