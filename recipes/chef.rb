#
# Cookbook Name:: sys
# Recipe:: chef
#
# set's up the chef-client
#
# Copyright 2011-2023 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

chef_client = "#{node['sys']['chef']['product_name']}-client"

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

template "/etc/default/#{chef_client}" do
  source 'etc_default_chef_client.erb'
  owner 'root'
  group 'root'
  mode "0644"
  variables(
    :interval => node['sys']['chef']['interval'],
    :splay    => node['sys']['chef']['splay']
  )
end

package 'ruby-sysloglogger' if node['sys']['chef']['use_syslog']

directory node['sys']['chef']['config_dir'] do
  owner 'root'
  group node['sys']['chef']['group']
  mode  0o0750
end

link '/etc/chef' do
  to node['sys']['chef']['config_dir']
  not_if { node['sys']['chef']['product_name'] == 'chef' }
end

# compile attributes for the client.rb template:
v              = node['sys']['chef'].to_hash
v[:server_url] = server_url
v[:opath]      = node['ohai']['plugin_path']
v[:odisable]   = node['ohai']['disabled_plugins']

template "#{node['sys']['chef']['config_dir']}/client.rb" do
  source 'etc_chef_client.rb.erb'
  owner 'root'
  group node['sys']['chef']['group']
  mode "0644"
  variables v
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
  # don't create the file:
  only_if { ::File.exist?(node['sys']['chef']['client_key']) }
end

# systemd-timer setup required systemd_unit resource which only became available in
#  Chef 12.11
if node['sys']['chef']['init_style'] == 'systemd-timer' &&
   Gem::Requirement.new('< 12.11')
     .satisfied_by?(Gem::Version.new(Chef::VERSION))
  Chef::Log.warn "Chef #{Chef::VERSION} too old for systemd-timer config of chef-client. Falling back to daemon mode"
  init_style = 'daemon'
else
  init_style = node['sys']['chef']['init_style']
end

if init_style == 'systemd-timer'

  # creates a one shot service and a systemd.timer to trigger it

  include_recipe 'sys::systemd'

  chef_service_unit = {
    'Unit' => {
      'Description' => 'Chef Infra Client',
      'After' => 'network.target auditd.service'
    },
    'Service' => {
      'Type' => 'oneshot',
      'EnvironmentFile' => "/etc/default/#{chef_client}",
      # TODO: do not start while dpkg is running
      # ExecCondition requires systemd >= 243 ie. Bullseye ...
      # 'ExecCondition' => "bash -c '/usr/bin/lockfile-check -l /var/lib/dpkg/lock && exit 255 || exit 0'",
      'ExecStart' => "/usr/bin/#{chef_client} -c $CONFIG -L $LOGFILE $OPTIONS",
      'ExecReload' => '/bin/kill -HUP $MAINPID',
      'SuccessExitStatus' => 3
    },
    'Install' => {
      'WantedBy' => 'multi-user.target',
      'Alias' => []
    }
  }

  chef_timer_unit = {
    'Unit' => { 'Description' => "#{chef_client} periodic run" },
    'Install' => {
      'WantedBy' => 'timers.target'
    },
    'Timer' => {
      'OnBootSec' => '30sec',
      # restart timer should be set to interval - splay - chef_run duration
      #  randomized delay is evenly distributed between 0 and splay
      #  median should be at splay/2, duration of chef_run is left out
      'OnUnitInactiveSec' => ( node['sys']['chef']['interval'].to_i -
                               node['sys']['chef']['splay'].to_i/2
                             ).to_s + 'sec',
      'RandomizedDelaySec' => "#{node['sys']['chef']['splay']}sec",
      'Unit' => "#{chef_client}-oneshot.service"
    }
  }

  # add alias to chef-client.service if we configure cinc:
  if node['sys']['chef']['product_name'] != 'chef'
    chef_service_unit['Install']['Alias'].push 'chef-client-oneshot.service'
    chef_timer_unit['Install']['Alias'] = 'chef-client.timer'
  end

  # mimic the chef-client cookbook systemd unit:
  systemd_unit "#{chef_client}-oneshot.service" do
    content chef_service_unit
    # what effect has stop when this chef run was started by systemd timer?
    action %i[create stop]
    notifies :run, 'execute[sys-systemd-reload]', :immediately
  end

  # mimic the chef-client cookbook systemd unit:
  systemd_unit "#{chef_client}.timer" do
    content chef_timer_unit
    action [:create, :enable, :start]
    notifies :run, 'execute[sys-systemd-reload]'
  end

else

  # normal systemd/sysvinit service

  # Comments in systemctl-src say that update-rc.d does not provide
  # information wheter a service is enabled or not and always returns
  # false.  Work around that.
  actions = [:start]
  actions << :enable if Dir.glob("/etc/rc2.d/*#{chef_client}*").empty?

  service chef_client do
    supports :restart => true, :status => true
    action actions
    ignore_failure true
    subscribes :restart, "template[/etc/default/#{chef_client}]"
    subscribes :restart, "template[#{node['sys']['chef']['config_dir']}/client.rb]"
  end

  # Create a script in cron.hourly to make sure chef-client keeps running
  if node['sys']['chef']['restart_via_cron'] # ~FC023
    template "/etc/cron.hourly/#{chef_client}" do
      source 'etc_cron.hourly_chef-client.erb'
      mode   '0755'
      helpers(Sys::Helper)
    end
  end

end
