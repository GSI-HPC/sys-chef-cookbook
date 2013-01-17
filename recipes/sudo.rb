#
# Cookbook Name:: sys
# Recipe:: sudo
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

unless node.sys.sudo.empty?

    package 'sudo'

    # make sure to keep the right permissions and ownership
    # on this file.
    template '/etc/sudoers' do
      source 'etc_sudoers.erb'
      owner 'root'
      group 'root'
      mode 0440
    end
    # system specific configurations should be applied by
    # individual files in this directory
    directory '/etc/sudoers.d' do
      owner 'root'
      group 'root'
      mode 0755
    end

    node.sys.sudo.each_pair do |name,config|
      sys_sudo name do
        users config[:users] if config.has_key? 'users'
        hosts config[:hosts] if config.has_key? 'hosts'
        commands config [:commands] if config.has_key? 'commands'
        rules config[:rules]
      end
    end

end
