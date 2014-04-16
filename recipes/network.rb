#
# Cookbook Name:: sys
# Recipe:: network
#
# Copyright 2012, Victor Penso
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

unless node.sys.network.vlan_bridges.empty?
  node.sys.network.vlan_bridges.each do |bridge|
    sys_network_vlan_bridge bridge do
      interface node.network.default_interface
    end
  end
end

interfaces = node.sys.network.interfaces
unless interfaces.empty?
  
  # FIXME: we only need these packages if we actually mess with VLANs
  package 'vlan'
  package 'bridge-utils'

  service 'networking'

  directory '/etc/network/interfaces.d'

  if node[:sys][:network][:keep_interfaces]
    unless system('grep -q "^source /etc/network/interfaces\.d/*" /etc/network/interfaces') 
      File.open("/etc/network/interfaces", "a") do |intf|
        intf.puts "\n#added by Chef:\nsource /etc/network/interfaces.d/*"
      end
    end
  else
    cookbook_file '/etc/network/interfaces' do
      source 'etc_network_interfaces'
    end
  end
  
  interfaces.each do |name,params|

    # set defaults
    inet = params.has_key?(:inet) ? params[:inet] : 'manual'
    auto = params.has_key?(:auto) ? params[:auto] : true

    # merge the configuration
    config = Array.new
    params.each do |key,value| 
      unless ["inet", "auto"].include? key
        config << "  #{key} #{value}" 
      end
    end

    # try to get configuration of the default interface from Ohai
    if name == node.network.default_interface and inet == 'static'
      config[:address] = node.ipaddress unless config.has_key?(:address)
      config[:gateway] = node.network.default_gateway unless config.has_key?(:gateway)
      config[:broadcast] = node.network.interfaces[node.network.default_interface].addresses[config[:address]].broadcast unless config.has_key?(:broadcast)
      config[:netmask] = node.network.interfaces[node.network.default_interface].addresses[config[:address]].netmask unless config.has_key?(:netmask)
    end

    template "/etc/network/interfaces.d/#{name}" do
      source 'etc_network_interfaces.d_generic.erb'
      mode "0644"
      variables(
        :auto => auto,
        :name => name,
        :inet => inet,
        :config => config
      )
      if node.sys.network.restart
        notifies :restart, 'service[networking]'
      end
    end

  end

end
