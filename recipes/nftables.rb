#
# Cookbook Name:: sys
# Recipe:: nftables
#
# Copyright 2014, HPC Team
#

unless node['sys']['nftables'].empty?

  if node['debian'] && node['debian']['codename'] && node['debian']['codename'].eql?('stretch')

    
  end
end
