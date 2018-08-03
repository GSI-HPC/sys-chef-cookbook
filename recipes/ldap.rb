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

if ! node['sys']['ldap'].empty? && File.exist?('/usr/bin/kinit')
  %w(
    nslcd
    libnss-ldapd
    ldap-utils
  ).each { |p| package p }

  sys_wallet "nslcd/#{node['fqdn']}" do
    place "/etc/nslcd.keytab"
    owner "nslcd"
    group "nslcd"
  end

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
      :servers => node['sys']['ldap']['servers'],
      :searchbase => node['sys']['ldap']['searchbase'],
      :realm => node['sys']['ldap']['realm'].upcase,
      :nss_initgroups_ignoreusers => begin
                                       node['sys']['ldap']['nss_initgroups_ignoreusers']
                                     rescue NoMethodError
                                       nil
                                     end,
      :nslcd => begin node['sys']['ldap']['nslcd'] rescue NoMethodError nil end
    )
  end

  # The ldap.conf configuration file is used to set system-wide defaults for ldap-client applications
  template "/etc/ldap/ldap.conf" do
    source "etc_ldap_ldap.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :servers => node['sys']['ldap']['servers'],
      :searchbase => node['sys']['ldap']['searchbase'],
      :realm => node['sys']['ldap']['realm'].upcase,
      :cacert => begin node['sys']['ldap']['cacert'] rescue nil end
    )
  end

  if node['platform_version'].to_i >= 9

    sys_systemd_unit 'nslcd.service' do
      config({
        'Unit' => {
          'Documentation' => 'man:nslcd',
          'Description' => 'Name service lookup daemon',
          'Before' => ['graphical.target', 'xdm.service', 'nscd.service'],
          'After' => 'k5start-nslcd.service',
          'BindsTo' => 'k5start-nslcd.service',
          #'JoinsNamespaceOf' => 'k5start-nslcd.service',
        },
        'Service' => {
          'Type' => 'forking',
          'ExecStart' => '/usr/sbin/nslcd',
          'Restart' => 'on-failure',
          'TimeoutSec' => '5min',
          #'PrivateTmp' => 'yes',
        },
        'Install' => {
          'WantedBy' => 'gsi-remote.target',
        }
      })
      notifies :restart, 'service[nslcd]'
    end

    sys_systemd_unit 'k5start-nslcd.service' do
      config({
        'Unit' => {
          'Description' => 'Maintain Ticket-Cache for nslcd',
          'Documentation' => ['man:k5start(1)', 'man:nslcd(8)'],
          'After' => 'network-online.target',
          'Requires' => 'network-online.target',
          'Before' => 'nslcd.service',
        },
        'Service' => {
          'Type' => 'forking',
          'ExecStart' => '/usr/bin/k5start -b -L -F -o nslcd -g nslcd -f /etc/nslcd.keytab -K 60 -k /tmp/krb5cc_nslcd -U -x',
          'Restart' => 'always',
          'RestartSec' => '5',
          #'PrivateTmp' => 'yes',
        },
        'Install' => {
          'WantedBy' => 'gsi-remote.target',
        }
      })
      notifies :restart, 'service[k5start-nslcd]'
    end

    service 'k5start-nslcd' do
      supports :restart => true, :reload => true
      action [:enable, :start]
    end

  else
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
  end
  # Comments in systemctl-src say that update-rc.d does not provide
  # information wheter a service is enabled or not and always returns
  # false.  Work around that.
  actions = [:start]
  actions << :enable if Dir.glob('/etc/rc2.d/*nslcd*').empty?
  actions << :enable if node['platform_version'].to_i >= 9

  service "nslcd" do
    supports :restart => true
    action actions
  end
end
