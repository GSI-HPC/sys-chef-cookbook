#
# Cookbook Name:: sys
# Recipe:: networkd
#
# Copyright 2017, Matthia Pausch
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

if node['platform_version'].to_i >= 9 && !node['sys']['networkd'].empty?

  delete = Dir.glob('/etc/systemd/network/*')
  keep = []

  node['sys']['networkd']['rename'].each do |_, name|
    keep << "00-#{name}.link"
  end

  node['sys']['networkd']['netdev'].each do |name, config|
    number_prefix = ''
    unless name.match(/^[0-9]{2}-/)
      number_prefix = '10-'
    end
    keep << "#{number_prefix}#{name}.netdev"
  end

  node['sys']['networkd']['network'].each do |name, config|
    number_prefix = ''
    unless name.match(/^[0-9]{2}-/)
      number_prefix = '20-'
    end
    keep << "#{number_prefix}#{name}.network"
  end

  keep.map!{|e| "/etc/systemd/network/#{e}"}

  (delete - keep).each do |f|
    file f do
      action :delete
    end
  end

  node['sys']['networkd']['rename'].each do |mac, name|
    template "/etc/systemd/network/00-#{name}.link" do
      source "systemd_networkd_generic.erb"
      helpers(Sys::Harry)
      mode "0644"
      variables(:sections => {'Match' => {'MACAddress' => mac}, 'Link' => {'Name' => name}})
    end
  end

  node['sys']['networkd']['netdev'].each do |name, config|
    number_prefix = ''
    unless name.match(/^[0-9]{2}-/)
      number_prefix = '10-'
    end
    template "/etc/systemd/network/#{number_prefix}#{name}.netdev" do
      source "systemd_networkd_generic.erb"
      helpers(Sys::Harry)
      mode "0644"
      variables(:sections => config)
    end
  end

  node['sys']['networkd']['network'].each do |name, config|
    number_prefix = ''
    unless name.match(/^[0-9]{2}-/)
      number_prefix = '20-'
    end
    template "/etc/systemd/network/#{number_prefix}#{name}.network" do
      source "systemd_networkd_generic.erb"
      helpers(Sys::Harry)
      mode "0644"
      variables(:sections => config)
    end
  end
end
