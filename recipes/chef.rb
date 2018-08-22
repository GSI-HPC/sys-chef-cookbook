# -*- coding: utf-8 -*-
#
# Cookbook Name:: sys
# Recipe:: chef
#
# set's up the chef-client
#
# Copyright 2011-2018 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH <hpc@gsi.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# All rights reserved - Do Not Redistribute
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

# Comments in systemctl-src say that update-rc.d does not provide
# information wheter a service is enabled or not and always returns
# false.  Work around that.
actions = [:start]
actions << :enable if Dir.glob('/etc/rc2.d/*chef-client*').empty?

service 'chef-client' do
  supports :restart => true, :status => true
  action actions
  ignore_failure true
end
