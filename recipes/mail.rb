#
# Cookbook Name:: sys
# Recipe:: mail
#
# Copyright 2012-2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Victor Penso       <v.penso@gsi.de>
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

%w[canonical virtual].each do |map|
  template "/etc/postfix/#{map}" do
    source 'etc_postfix_postmap.erb'
    mode '0600'
    variables(
      entries: node['sys']['mail'][map] || {}
    )
    notifies :run, "execute[update-#{map}]", :immediately
  end

  execute "update-#{map}" do
    action :run
    command "postmap /etc/postfix/#{map}"
    # check if /etc/postfix/<map>.db exists and
    #  run if it doesn't or is outdated:
    not_if "/usr/bin/test /etc/postfix/#{map}.db -nt /etc/postfix/#{map}"
    notifies :reload, 'service[postfix]'
  end
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
