#
# Cookbook Name:: snmp
# Recipe:: default
#
# Copyright 2011, GSI Darmstadt
#
# All rights reserved - Do Not Redistribute
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
  
  service 'snmpd' do
    action [:enable, :start]
  end
  
end
