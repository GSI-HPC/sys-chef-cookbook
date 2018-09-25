#
# Cookbook Name:: ohai
# Recipe:: default
#
# Copyright 2010, Opscode, Inc
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

# TODO: use ohai_plugin provider from ohai cookbook?
# return unless node['ohai']['install_plugins']

# node['ohai']['install_plugins'].each do plugin
#   ohai_plugin plugin do
#     path node['ohai']['plugin_path']
#   end
# end

log "ohai plugins will be at: #{node['ohai']['plugin_path']}" do
  level :info
end

ohai "reload" do
  action :nothing
end

# Copy plugins into the plugin directory
remote_directory node['ohai']['plugin_path'] do
  source 'ohai_plugins'
  owner 'root'
  group 'root'
  mode "0755"
  action :create
  notifies :reload, "ohai[reload]", :immediately
end

if node['ohai']['update_pciids']
  package 'pciutils'

  cron 'update-pciids' do
    weekday 6
    hour 12
    command 'update-pciids -q'
    only_if File.exist?('/usr/bin/update-pciids')
  end
end
