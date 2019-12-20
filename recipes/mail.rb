#
# Cookbook Name:: sys
# Recipe:: mail
#
# Copyright 2012 - 2019, GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
# Authors:
#   Victor Penso
#   Dennis Klein
#   Christopher Huhn
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

relay = node['sys']['mail']['relay']

return if relay.empty?

update_virtual = 'Update Postfix virtual aliases'
etc_postfix_virtual = '/etc/postfix/virtual'

update_aliases = 'Update Postfix aliases'
etc_aliases = '/etc/aliases'

maincf_vars = {
  relay:              relay,
  mynetworks:         node['sys']['mail']['mynetworks'],
  inet_interfaces:    node['sys']['mail']['inet_interfaces'],
  ipv4_only:          node['sys']['mail']['disable_ipv6'],
  default_privs:      node['sys']['mail']['default_privs'],
  mydestination:      node['sys']['mail']['mydestination'],
  relay_domains:      node['sys']['mail']['relay_domains'],
  message_size_limit: node['sys']['mail']['message_size_limit'],
  virtual_alias_maps: "hash:#{etc_postfix_virtual}",
}

if node['sys']['mail']['export_environment']
  maincf_vars[:export_environment] =
    (node['sys']['mail']['export_environment'] + %w[TZ MAIL_CONFIG LANG]).uniq
end

package 'postfix'
service 'postfix' do
  supports :reload => true
end

file '/etc/mailname' do
  content "#{node['fqdn']}\n"
end

template '/etc/postfix/main.cf' do
  source 'etc_postfix_main.cf.erb'
  mode '0644'
  variables maincf_vars
  # after changes to main.cf postfix - sometimes - has to be restarted
  notifies :restart, 'service[postfix]'
end

template '/etc/postfix/canonical' do
  source 'etc_postfix_canonical.erb'
  mode '0600'
  notifies :run, 'execute[update-canonical]', :immediately
end

execute 'update-canonical' do
  action :run
  command 'postmap /etc/postfix/canonical'
  # check if /etc/postfix/canonical.db exists and
  #  run if it doesn't or is outdated:
  not_if 'test /etc/postfix/canonical.db -nt /etc/postfix/canonical'
  notifies :reload, 'service[postfix]'
end

execute update_virtual do
  action :nothing
  command "postmap #{etc_postfix_virtual}"
  notifies :reload, 'service[postfix]'
end

template etc_postfix_virtual do
  source 'etc_postfix_virtual.erb'
  mode '0600'
  variables({
              :map => node['sys']['mail']['virtual'] || {}
            })
  notifies :run, "execute[#{update_virtual}]", :immediately
end

execute update_aliases do
  action :nothing
  command "postalias #{etc_aliases}"
  notifies :reload, 'service[postfix]'
end

node['sys']['mail']['aliases'].each do |account, mail_address|
  sys_mail_alias account do
    to mail_address
    aliases_file etc_aliases
    notifies :run, "execute[#{update_aliases}]", :delayed
  end
end
