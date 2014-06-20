#
# Cookbook Name:: sys
# Recipe:: boot
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

unless node.sys.boot.params.empty? and node.sys.boot.config.empty?

  package 'lsb-release'

  sys_shutdown "now" do
    action :nothing
  end

  update_grub = 'Updating Grub boot configuration'
  execute update_grub  do
    action :nothing
    command 'update-grub2'
    notifies :reboot, "sys_shutdown[now]", :immediately
  end

  template '/etc/default/grub' do
    source 'etc_default_grub.erb'
    mode "0644"
    variables(
      :bootfest => node.sys.boot.bootfest.join(' ')
      :params => node.sys.boot.params.join(' '),
      :config => (node.sys.boot.config.map { |k,v| %Q[#{k}="#{v}"] }).join("\n")
    )
    notifies :run, "execute[#{update_grub}]", :immediately
  end

end
