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
    source 'etc_snmp_snmpd_conf.erb'
    notifies :restart, "service[snmpd]"
    variables({
        # Default: Listen on loopback only 
        :agent_address => node['sys']['snmp']['agent_address'] || 'udp:127.0.0.1:161',
        :sys_contact   => node['sys']['snmp']['sys_contact']   || "Sysadmins <root@#{node['fqdn']}>"
        :sys_location  => node['sys']['snmp']['sys_location' ] # no default here
        :extensions    => { :pass => node['sys']['snmp']['extensions']['pass'] || []
      })
  end
  
  service 'snmpd' do
    action [:enable, :start]
  end
  
end
