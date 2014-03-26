#
# Cookbook Name:: sys
# Recipe:: tmp
#
# Copyright 2013, Bastian Neuburger, Victor Penso
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

unless node.sys.tmp.empty?

  unless node.sys.tmp.reaper.empty?

    package 'tmpreaper'

    unless node.sys.tmp.reaper.has_key? 'disabled'
      node.set[:sys][:tmp][:reaper][:disabled] = false
    end

    template '/etc/tmpreaper.conf' do
      source 'etc_tmpreaper.conf.erb'
      mode "0644"
      variables(
        :disabled => node.sys.tmp.reaper.disabled,
        :max_age => node.sys.tmp.reaper.max_age,
        :protected_patterns => node.sys.tmp.reaper.protected_patterns,
        :dirs => node.sys.tmp.reaper.dirs,
        :options => node.sys.tmp.reaper.options
      )
    end

  end 

end


