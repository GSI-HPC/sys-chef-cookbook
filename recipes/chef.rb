# -*- coding: utf-8 -*-
#
# Cookbook Name:: sys
# Recipe:: chef
#
# set's up the chef-client
#
# $Id$
#
# Copyright 2011-2013 GSI Helmholtzzentrum für Schwerionenforschung GmbH <hpc@gsi.de>
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

if node['sys']['chef']['use_syslog']
  package 'ruby-sysloglogger'
end

server_url = node['sys']['chef']['server_url']

begin
  unless server_url or not node['chef']['server']['fqdn']
    # fallback for figuring out the chef server url following the "old" conventions
    #  introduced by the chef cookbook
    if node['chef']['server']['ssl']
      server_url = 'https://#{server}:443'
    else
      server_url = 'http://#{server}:4000'
    end
  end
rescue ArgumentError => e
  Chef::Log.debug e
end

# configuring the chef client only makes sense if the server is defined:
if server_url

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
else
  log("No chef server defined. Please set node['sys']['chef']['server_url'] to point to your chef server") { level :warn }
end

# Delete the validation credential if the machines
# has already registered with the server, unless
# the node is a server itself, since if this is the
# case, the validation key would be regenerated on
# each chef-server restart.
# For now we assume that the chef server does not run sys::chef
#unless node['chef']['is_server']
file node['sys']['chef']['validation_key'] do
  action :delete
  backup false
  only_if do ::File.exist? node['sys']['chef']['client_key'] end
end
#end

# make the client key group-readable
#  (so its members can use 'knife .. -c /etc/chef/client.pem')
file node['sys']['chef']['client_key'] do
  group node['sys']['chef']['group']
  mode "0640"
end

# Create a script in cron.hourly to make sure chef-client keeps running
if node['sys']['chef']['restart_via_cron'] # ~FC023
  template '/etc/cron.hourly/chef-client' do
    source 'etc_cron.hourly_chef-client.erb'
    mode '0755'
    helpers(Sys::Helper)
  end
end

service 'chef-client' do
  supports  :restart => true, :status => true
  action   [ :enable, :start ]
end

