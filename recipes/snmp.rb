#
# Cookbook Name:: sys
# Recipe:: snmp
#
# Copyright 2011-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
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

return unless node['sys']['snmp']

# some defaults:

snmpd_package = 'snmpd'
snmpd_defaults = '/etc/default/snmpd'
snmpd_user = 'snmp'
snmpd_group = 'snmp'

log_levels = %w[emerg alert crit err warn notice info debug]

# for snmpd config we have to turn the log_level ids into numbers:
#  default is 'warn', snmpd log with 'notice' by default
log_level_num = log_levels.rindex(node['sys']['snmp']['log_level']) || 4

case node['platform_family']
when 'rhel'
  snmpd_package = 'net-snmp'
  snmpd_defaults = '/etc/sysconfig/snmpd'

  # Redhat runs snmpd as root by default
  #  let's create a snmp user and group instead
  group snmpd_group do
    system true
  end

  user snmpd_user do
    system true
    home '/var/lib/snmp'
    shell '/usr/sbin/nologin'
    gid 'snmp'
  end
when 'debian'
  # different user name on Stretch and beyond:
  unless node['platform_version'].to_i < 9
    snmpd_user = 'Debian-snmp'
    snmpd_group = 'Debian-snmp'
  end
end

package snmpd_package

# the systemd unit shipped by Debian does not take
#  `/etc/default/snmpd` into account
#  (and the latter is no EnvironmentFile but a shell script)
if node['platform_family'] == 'debian' && node['platform_version'].to_i >= 9

  directory '/etc/systemd/system/snmpd.service.d/'

  file '/etc/systemd/system/snmpd.service.d/override.conf' do
    content <<EOF
# DO NOT CHANGE THIS FILE MANUALLY!
#
# This file is managed by chef.
# Created by sys::snmp

[Service]
ExecStart=
ExecStart=/usr/sbin/snmpd -LS#{log_level_num}d -Lf /dev/null \\
    -u #{snmpd_user} -g #{snmpd_user} -I -smux,mteTrigger,mteTriggerConf \\
    -f -p /run/snmpd.pid
EOF
    notifies :run, 'execute[sys-systemd-reload]'
  end

  include_recipe 'sys::systemd' # for systemctl daemon-reload
else

  template snmpd_defaults do
    source 'etc_default_snmpd.erb'
    mode 0644
    variables(
      user:  snmpd_user,
      group: snmpd_group,
      log_level: log_level_num
    )
    notifies :restart, "service[snmpd]"
  end

end

template '/etc/snmp/snmpd.conf' do
  mode 0600
  source 'etc_snmp_snmpd.conf.erb'
  notifies :restart, "service[snmpd]"
  variables(
    # Sane defaults are defined in the template if these are nil:
    :agent_address => node['sys']['snmp']['agent_address'],
    :community     => node['sys']['snmp']['community'],
    :extensions    => node['sys']['snmp']['extensions'] || [],
    :full_access   => node['sys']['snmp']['full_access'],
    :sys_contact   => node['sys']['snmp']['sys_contact'] ||
                      "Sysadmins <root@#{node['fqdn']}>",
    :sys_location  => node['sys']['snmp']['sys_location']
  )
end


# TODO: for now the defaultMonitors are turned off, they produce bogus error
#       messages  service startup  MIBs are available
#       (package 'snmp-mibs-downloader')
#       and configured in /etc/default/snmpd ('export MIBS=/usr/share/mibs')

service 'snmpd' do
  action [:enable, :start]
end

# add SNMPv3 users:
if node['sys']['snmp']['snmpv3_users']

  package 'libsnmp-dev' do
    # In Jessie net-snmp-config moved to this package:
    only_if { node['platform_version'].to_f >= 8.0 }
  end

  # snmpd must not run during net-snmp-config
  service 'stop_snmpd' do
    service_name 'snmpd'
    action :stop
  end

  node['sys']['snmp']['snmpv3_users'].each do |u|
    execute "create_snmpv3_user_#{u['securityName']}" do
      command "net-snmp-config --create-snmpv3-user" +
              " #{'-ro' unless u['readonly'] == false} -A #{u['authKey']} " +
              " -X #{u['privKey']} -a #{u['authProtocol'] || 'SHA'}" +
              " -x #{u['privProtocol'] || 'AES'} #{u['securityName']}"
      notifies :start, "service[snmpd]", :delayed
    end
  end
end
