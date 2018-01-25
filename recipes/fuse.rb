#
# Cookbook Name:: sys
# Recipe:: fuse
#
# Copyright 2013, Victor Penso
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

unless node['sys']['fuse']['config'].empty?

  package 'fuse'

  template '/etc/fuse.conf' do
    source 'etc_fuse.conf.erb'
    # 0644 root:root perfectly fine for this file
    variables :config => node['sys']['fuse']['config']
  end

  service 'udev' do
    supports :restart => true
    only_if { node['platform_version'].to_i == 7 }
    subscribes :reload, 'template[/etc/fuse.conf]'
  end

end
