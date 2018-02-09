#
# Cookbook Name:: sys
# Recipe:: sudo
#
# Copyright 2012, Victor Penso
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

if ! node['sys']['sudo'].empty? && node['sys']['sudo_ldap'].empty?

    package 'sudo'

    # Prevent "undefined method `[]' for nil:NilClass":
    if node['sys']['sudo']['config']
      mailto = node['sys']['sudo']['config']['mailto']
    end

    # make sure to keep the right permissions and ownership
    # on this file.
    template '/etc/sudoers' do
      source 'etc_sudoers.erb'
      owner 'root'
      group 'root'
      mode "0440"
      variables(
        mailto: mailto
      )
    end

    # system specific configurations should be applied by
    # individual files in this directory
    directory '/etc/sudoers.d' do
      owner 'root'
      group 'root'
      mode "0755"
    end

    # filter out config branch from attribute tree:
    node['sys']['sudo'].reject do |key|
      key.to_s == 'config'
    end.each_pair do |name,config|
      sys_sudo name do
        users config[:users] if config.has_key? 'users'
        hosts config[:hosts] if config.has_key? 'hosts'
        commands config [:commands] if config.has_key? 'commands'
        rules config[:rules]
      end
    end
elsif ! node['sys']['sudo_ldap'].empty?
  package 'sudo-ldap'

  sys_wallet "sudoers/#{node['fqdn']}" do
    place "/etc/sudoers.keytab"
    owner "root"
    group "root"
    mode "0600"
  end

  template '/etc/sudoers' do
    source 'etc_sudoers_ldap.erb'
    owner 'root'
    group 'root'
    mode '0400'
  end

  template "/etc/sudo-ldap.conf" do
    source 'etc_sudo-ldap.conf.erb'
    owner 'root'
    group 'root'
    mode  '0400'
    variables(
      servers: node['sys']['sudo_ldap']['servers']
    )
  end
end
