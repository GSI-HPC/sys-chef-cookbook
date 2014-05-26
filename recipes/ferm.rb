#
# Cookbook Name:: sys
# Recipe:: ferm
#
# Copyright 2014, HPC Team
#

unless node.sys.ferm.table.empty?
  package 'ferm' do
    action :upgrade
  end

  fermserviceaction = :enable
  fermaction = :start

  unless node.sys.ferm.active
    fermserviceaction = :disable
    fermaction = :stop
  end

  unless node.sys.ferm.foreign_config
    template '/etc/ferm/ferm.conf' do
      source 'etc_ferm_ferm.conf.erb'
      mode   '0644'
      owner  'root'
      group  'adm'
    end
  end

  service 'ferm' do
    action [ fermaction, fermserviceaction ]
  end
end
