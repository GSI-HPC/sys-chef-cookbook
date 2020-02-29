#
# Cookbook Name:: sys
# Recipe:: ferm
#
# Copyright 2014-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
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

class Chef::Recipe::SysFermSanityCheckError < RuntimeError
end

unless node['sys']['ferm']['rules'].empty?
  # Sanity checks
  node['sys']['ferm']['rules'].each do |domain, tables|
    unless /^((\((ip6?|eb|arp)( (ip6?|eb|arp))*\))|(ip6?|eb|arp))$/.match domain.to_s
      raise Chef::Recipe::SysFermSanityCheckError, "Insane ferm domain '#{domain}'."
    end
    tables.each do |table,chains|
      unless /^((\((filter|nat|mangle)( (filter|nat|mangle))*\))|(filter|nat|mangle))$/.match table.to_s
        raise Chef::Recipe::SysFermSanityCheckError, "Insane ferm table '#{table}' within domain '#{domain}'."
      end
      chains.each do |chain,rules|
        unless /^[A-Z_]+$/.match chain.to_s
          raise Chef::Recipe::SysFermSanityCheckError, "Insane ferm chain '#{chain}' within domain/table '#{domain}/#{table}'."
        end
        rules.each do |rule|
          unless /((^#.*)|(^[ ]*$)|(.*;$))/.match rule
            raise Chef::Recipe::SysFermSanityCheckError, "Insane ferm rule '#{rule}' within domain/table/chain '#{domain}/#{table}/#{chain}'"
          end
        end
      end
    end
  end

  package 'ferm' do
    action :upgrade
  end

  fermserviceaction = :enable
  fermaction = :start

  unless node['sys']['ferm']['active']
    fermserviceaction = :disable
    fermaction = :stop
  end

  template (node['platform_family'] == 'debian') ? '/etc/ferm/ferm.conf' : '/etc/ferm.conf' do
    source 'etc_ferm_ferm.conf.erb'
    mode   '0644'
    owner  'root'
    group  'adm'
    notifies :reload, 'service[ferm]', :immediately
    not_if { node['sys']['ferm']['foreign_config'] }
  end

  service 'ferm' do
    supports :reload => true, :restart => true
    action [ fermaction, fermserviceaction ]
  end
end
