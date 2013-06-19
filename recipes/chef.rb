# -*- coding: iso-8859-15 -*-
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
  mode 0644
  variables(
    :interval => node.sys.chef.interval,
    :splay => node.sys.chef.splay
  )
  notifies :restart, "service[chef-client]"
end

if node.sys.chef.use_syslog
  package 'ruby-sysloglogger'
end

server_url = node.sys.chef.server_url

begin
  unless server_url or not node.chef.server.fqdn
    # fallback for figuring out the chef server url following the "old" conventions 
    #  introduced by the chef cookbook
    if server = node.chef.server.ssl
      server_url = 'https://#{server}:443'    
    else
      server_url = 'http://#{server}:4000'
    end
  end
rescue ArgumentError => e
  # ignore
end

# configuring the chef client only makes sense if the server is defined:
if server_url
  
  template '/etc/chef/client.rb' do
    source 'etc_chef_client.rb.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables(
              :server_url => server_url,
              :opath      => node.ohai.plugin_path,
              :odisable   => node.ohai.disabled_plugins,
              :syslog     => node.sys.chef.use_syslog
              )
    notifies :restart, "service[chef-client]"
  end
else
  log("No chef server defined. Please set node.sys.chef.server_url to point to your chef server") { level :warn }
end

# Delete the validation credential if the machines
# has already registered with the server, unless
# the node is a server itself, since if this is the 
# case, the validation key would be regenerated on
# each chef-server restart.
# For now we assume that the chef server does not run sys::chef
#unless node.chef.is_server
file node.sys.chef.validation_key do
  action :delete
  backup false
  only_if do ::File.exists? node.sys.chef.client_key end
end
#end

# Create a script in cron.hourly to make sure chef-client keeps running
#cookbook_file "/etc/cron.hourly/chef-client-service" do
#  source "chefclientcronjob"
#  mode 0755
#end

service 'chef-client' do
  supports :restart => true
  action :enable
end

# Periodically check if cron is running
#service "cron" do
#  action [ :enable, :start ]
#end
