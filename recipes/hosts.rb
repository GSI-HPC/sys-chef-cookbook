#
# Cookbook Name:: sys
# Recipe:: hosts
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

unless node.sys.hosts.file.empty?
  template '/etc/hosts' do
    source 'etc_hosts.erb'
    mode '0664'
    variables( :addresses => node.sys.hosts.file )
  end
end

unless node.sys.hosts.allow.empty?
  template '/etc/hosts.allow' do
    source 'etc_hosts.allow.erb'
    mode '0644'
    variables( :rules => node.sys.hosts.allow )
  end
end

unless node.sys.hosts.deny.empty?
  template '/etc/hosts.deny' do
    source 'etc_hosts.deny.erb'
    mode '0644'
    variables( :rules => node.sys.hosts.deny )
  end
end
