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
Chef::Resource.send(:include, Sys::Helper)

if systemd_installed? # We do not install systemd for now, just detect if it is available

  if node['sys']['systemd']['networkd']['clean_legacy']
    # This works for current usecases, but may be too radical. Probably needs
    # to be changed again, when we understand, how to use systemd-networkd.service
    # in other scenarios

    interfacesd = '/etc/network/interfaces.d/*'
    execute "rm -rf #{interfacesd}" do
      not_if { Dir[interfacesd].empty? }
    end

    file '/etc/network/interfaces' do
      content "# No longer used, see SYSTEMD-NETWORKD.SERVICE(8)\n"
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
    if systemd_active?
      service 'systemd-networkd' do
        supports restart: true
        action [ :enable, :start ]
      end
    else
      # We might be in a chroot
      execute 'systemctl enable systemd-networkd.service'
    end
  end

  if node['sys']['systemd']['networkd']['make_primary_interface_persistent']
    # This uses ohai data, so any manual change to the network interface
    # will be made permanent. This flag is intended to be used by a one-time
    # mechanism like an OS installer.

    interface = node['network']['default_interface'].to_s
    ipaddress = node['ipaddress'].to_s
    gateway = node['network']['default_gateway'].to_s
    cidr = node['network']['interfaces'][interface]['addresses'][ipaddress]['prefixlen'].to_s

    unless interface.empty? || ipaddress.empty? || gateway.empty? || cidr.empty? # ~FC023
      sys_systemd_unit "#{interface}.network" do
        directory '/etc/systemd/network'
        config({
          'Match' => {
            'Name' => interface
          },
          'Network' => {
            'Address' => "#{ipaddress}/#{cidr}",
          },
          'Route' => {
            'Gateway' => gateway
          }
        })
        action :create
        notifies(:restart, 'service[systemd-networkd]', :delayed) if systemd_active?
      end
    end
  end

end
