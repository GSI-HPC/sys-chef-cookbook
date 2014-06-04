#
# Cookbook Name:: snmp
# Recipe:: default
#
# Copyright 2011, GSI Darmstadt
#
# All rights reserved - Do Not Redistribute
#

if node['sys']['snmpd']

  # deny SNMP connections by default, explicitly whitelist hosts:
  default['sys']['hosts']['allow'] << "snmpd: #{node.sys.snmp.allow.join(', ')}"
  default['sys']['hosts']['deny']  << 'snmpd: ALL'

  include_recipe 'sys::hosts'
  
  package 'snmpd'
  
  template '/etc/snmp/snmpd.conf' do
    mode 0600
    source 'etc_snmp_snmpd_conf.erb'
    notifies :restart, "service[snmpd]"
  end
  
  service 'snmpd' do
    action [:enable, :start]
  end
  
end
