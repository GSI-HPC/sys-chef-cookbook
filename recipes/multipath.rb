#
# Cookbook:: sys
# Recipe:: multipath
#
# Copyright:: 2014-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Dennis Klein   <d.klein@gsi.de>
#  Thomas Roth    <t.roth@gsi.de>
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

config = node['sys']['multipath'].to_hash
config.delete('disable')
config.delete('regenerate_initramdisk')

unless config.empty?
  package 'multipath-tools'

  service 'multipathd' do
    supports :reload => true
    status_command 'ps -p $(cat /var/run/multipathd.pid)'
    if node['sys']['multipath']['disable']
      action [:disable]
    else
      action [:enable, :start]
    end
  end

  execute 'regenerate_initramdisk' do
    command '/etc/kernel/postinst.d/initramfs-tools `uname -r`'
    action :nothing
    only_if { node['sys']['multipath']['regenerate_initramdisk'] }
  end

  template '/etc/multipath.conf' do
    source 'etc_multipath.conf.erb'
    mode '0664'
    variables({
      :config => config
    })
    notifies :reload, 'service[multipathd]'
    if node['sys']['multipath']['regenerate_initramdisk']
      notifies :run, 'execute[regenerate_initramdisk]'
    end
  end
end
