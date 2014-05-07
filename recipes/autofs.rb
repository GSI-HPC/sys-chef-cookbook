#
# Cookbook Name:: sys
# Recipe:: autofs
#
# Copyright 2013, Victor Penso
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

if ! node.sys.autofs.maps.empty? && node.sys.autofs.ldap.empty?

  package 'autofs'

  node.sys.autofs.maps.each_key do |mountpoint|
    directory mountpoint do
      not_if { File.exists?(mountpoint) }
    end
  end

  template '/etc/auto.master' do
    source 'etc_auto.master.erb'
    mode "0644"
    variables(
      :maps => node.sys.autofs.maps
    )
    notifies :reload, 'service[autofs]'
  end

  #  node.sys.autofs.maps.each_key do |path|
  #    directory path do
  #      recursive true
  #    end
  #  end

  service 'autofs' do
    supports :restart => true, :reload => true
  end
end

unless node.sys.autofs.ldap.empty?
  package "autofs"
  package "autofs-ldap"
  package "kstart"

  template "/etc/auto.master" do
    source 'etc_auto.master.erb'
    mode "0644"
    variables(
      :maps => node.sys.autofs.maps
    )
    notifies :reload, 'service[autofs]'
  end

  template "/etc/autofs_ldap_auth.conf" do
    source "etc_autofs_ldap_auth.conf.erb"
    mode "0600"
    variables({
      :principal => node.fqdn,
      :realm => node.sys.krb5.realm.upcase
    })
    notifies :restart, 'service[autofs]', :delayed
  end

  template "/etc/default/autofs" do
    source "etc_default_autofs.erb"
    mode "0644"
    if node.sys.autofs.ldap.browsemode
      browsemode = "yes"
    else
      browsemode = "no"
    end

    variables({
      :uris => node.sys.autofs.ldap.servers,
      :searchbase => node.sys.autofs.ldap.searchbase,
      :browsemode => browsemode
    })
    notifies :restart, 'service[autofs]', :delayed
  end

  cookbook_file "/etc/init.d/autofs" do
    source "etc_init.d_autofs"
    mode "0755"
    notifies :restart, 'service[autofs]', :delayed
  end

  service 'autofs' do
    supports :restart => true, :reload => true
  end
end
