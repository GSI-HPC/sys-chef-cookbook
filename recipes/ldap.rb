#
# Cookbook Name:: sys
# Recipe:: ldap
#
# Copyright 2013, Matthias Pausch
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

if ! node.sys.ldap.empty? && File.exists?("/etc/nslcd.keytab")
  %w(
    nscd
    nslcd
    kstart
    libnss-ldapd
    ldap-utils
  ).each { |p| package p }

  node.default['sys']['ldap']['servers'] = [ node.sys.ldap.master, node.sys.ldap.slave ]

  # Environment variables for nslcd.  They mainly just configure k5start.
  template "/etc/default/nslcd" do
    source "etc_default_nslcd.conf.erb"
    user "root"
    group "root"
    mode "0644"
    notifies :restart, "service[nslcd]", :delayed
  end

  # Configuration for nslcd.  nlscd queries an ldap-server for user-information.
  template "/etc/nslcd.conf" do
    source "etc_nslcd.conf.erb"
    user "root"
    group "root"
    mode "0644"
    notifies :restart, "service[nslcd]", :delayed
    variables(
      :servers => node.sys.ldap.servers,
      :searchbase => node.sys.ldap.searchbase,
      :realm => node.sys.ldap.realm.upcase,
      :nss_initgroups_ignoreusers => begin node.sys.ldap.nss_initgroups_ignoreusers rescue nil end
    )
  end

  # The ldap.conf configuration file is used to set system-wide defaults for ldap-client applications
  template "/etc/ldap/ldap.conf" do
    source "etc_ldap_ldap.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :servers => node.sys.ldap.servers,
      :searchbase => node.sys.ldap.searchbase,
      :realm => node.sys.ldap.realm.upcase,
      :cacert => begin node.sys.ldap.cacert rescue nil end
    )
  end

  cookbook_file "/etc/init.d/nslcd" do
    source "etc_init.d_nslcd"
    owner "root"
    group "root"
    mode "0755"
    notifies :run, "execute[update-run-levels]", :immediately
  end

  execute "update-run-levels" do
    command "insserv /etc/init.d/nslcd"
    action :nothing
  end

  service "nslcd" do
    supports :restart => true
    action [:start, :enable]
    notifies :restart, "service[nscd]", :delayed
  end

  # nscd turned out to greatly improve performance
  service "nscd" do
    supports :restart => true
    action [:start, :enable]
    only_if 'test -e /etc/init.d/nscd'
  end
end
