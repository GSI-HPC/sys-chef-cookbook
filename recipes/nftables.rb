#
# Cookbook Name:: sys
# Recipe:: nftables
#
# Copyright 2014, HPC Team
#

unless node['sys']['nftables'].empty?

  if node['debian'] && node['debian']['codename'] && node['debian']['codename'].eql?('stretch')

    package 'nftables' do
      action :upgrade
    end

    # Future version will not include the init-script, cf. https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=804648
    file '/etc/init.d/nftables' do
      action :delete
    end

    nftables_serviceaction = :enable
    nftables_action = :start

    unless node['sys']['nftables']['active']
      nftables_serviceaction = :disable
      nftables_action = :stop
    end

    template '/etc/nftables.conf' do
      source 'etc_nftables.conf.erb'
      mode   '0644'
      owner  'root'
      group  'adm'
      notifies :reload, 'service[nftables]', :immediately
    end

    service 'nftables' do
      supports :reload => true, :restart => true
      action [ nftables_action, nftables_serviceaction ]
    end
  end
end
