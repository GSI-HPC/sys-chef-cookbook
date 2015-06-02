#
# Cookbook Name:: sys
# Recipe:: krb5
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

unless node['sys']['krb5'].empty?
  %w(
    heimdal-docs
    heimdal-clients
    libpam-heimdal
    heimdal-kcm
    libsasl2-modules-gssapi-heimdal
  ).each { |p| package p }

  template "/etc/krb5.conf" do
    source "etc_krb5.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :realm => node.default['sys']['krb5']['realm'].upcase,
      :admin_server => node.default['sys']['krb5']['admin_server'],
      :servers => [ node.default['sys']['krb5']['master'], node.default['sys']['krb5']['slave'] ],
      :domain => node['domain'],
      :wallet_server => begin node['sys']['krb5']['wallet_server'] rescue nil end,
      :use_pkinit => begin node['sys']['krb5']['use_pkinit'] rescue nil end
    )
  end

  package "wallet-client"

  sys_wallet "host/#{node['fqdn']}" do
    place "/etc/krb5.keytab"
  end

end
