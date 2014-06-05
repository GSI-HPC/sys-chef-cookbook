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
        :sys_contact   => node['sys']['snmp']['sys_contact'] || "Sysadmins <root@#{node['fqdn']}>",
        :sys_location  => node['sys']['snmp']['sys_location']
      })
  end

  # TODO: for now the defaultMonitors are turned off, they produce bogus error messages on service startup
  #       unless MIBs are available (package 'snmp-mibs-downloader') 
  #       and configured in /etc/default/snmpd ('export MIBS=/usr/share/mibs')

  service 'snmpd' do
    action [:enable, :start]
  end
  
end
