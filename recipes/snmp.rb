#
# Cookbook Name:: snmp
# Recipe:: default
#
# Copyright 2011, GSI Darmstadt
#
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


if node['sys']['snmp']

  package 'snmpd'

  template '/etc/default/snmpd' do
    source 'etc_default_snmpd.erb'
    mode 0644
    notifies :restart, "service[snmpd]"
  end

  template '/etc/snmp/snmpd.conf' do
    mode 0600
    source 'etc_snmp_snmpd.conf.erb'
    notifies :restart, "service[snmpd]"
    variables({
        # Sane defaults are defined in the template if these are nil:
        :agent_address => node['sys']['snmp']['agent_address'],
        :community     => node['sys']['snmp']['community'],
        :extensions    => node['sys']['snmp']['extensions'] || [],
        :full_access   => node['sys']['snmp']['full_access'],
        :sys_contact   => node['sys']['snmp']['sys_contact'] ||
                          "Sysadmins <root@#{node['fqdn']}>",
        :sys_location  => node['sys']['snmp']['sys_location']
      })
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

end
