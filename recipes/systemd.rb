#
# Cookbook Name:: sys
# Recipe:: systemd
#
# Copyright 2015, Dennis Klein
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

Chef::Recipe.send(:include, Sys::Helper)

if systemd? # We do not install systemd for now, just detect if it is available

  if node['sys']['systemd']['networkd']['clean_legacy']
    # This works for current usecases, but may be too radical. Probably needs
    # to be changed again, when we understand, how to use systemd-networkd.service
    # in other scenarios

    interfacesd = '/etc/network/interfaces.d/*'
    execute "rm -rf #{interfacesd}" do
      not_if { Dir[interfacesd].empty? }
    end

    file '/etc/network/interfaces' do
      content '# No longer used, see SYSTEMD-NETWORKD.SERVICE(8)'
    end
  end

  # Create custom units from attributes
  unless node['sys']['systemd']['unit'].empty?
    node['sys']['systemd']['unit'].each do |name, config|
      sys_systemd_unit name do
        config.each do |key, value|
          send(key, value)
        end
      end
    end
  end

  # Enable/Start systemd-networkd
  # This is e.g. needed for the systemd-networkd-wait-online.service to work.
  if node['sys']['systemd']['networkd']['enable']
    service 'systemd-networkd' do
      action [:enable, :start]
    end
  end

end
