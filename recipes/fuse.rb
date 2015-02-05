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

  package 'fuse-utils'

  template '/etc/fuse.conf' do
    source 'etc_fuse.conf.erb'
    mode '0640'
    owner 'root'
    group 'fuse'
    variables :config => node['sys']['fuse']['config']
    notifies :restart, 'service[udev]'
  end

  service 'udev' do
    supports :restart => true
  end

end
