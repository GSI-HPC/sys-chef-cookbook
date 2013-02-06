#
# Cookbook Name:: sys
# Recipe:: time
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

unless node.sys.nis.servers.empty?

  package 'nis'

  if node.sys.nis.domain.empty?
    node.default[:sys][:nis][:domain] = node.domain
  else
    template '/etc/defaultdomain' do
      source 'etc_generic.erb'
      variables(
        :file_name => '/etc/defaultdomain',
        :content => node.sys.nis.domain << "\n"
      )
    end
  end

  template '/etc/yp.conf' do
    source 'etc_yp.conf.erb'
    variables( 
      :domain => node.sys.nis.domain.chomp,
      :servers => node.sys.nis.servers 
    )
    notifies :restart, 'service[nis]'
  end

  service 'nis' do
    supports :restart => true
  end

end

package 'nscd' if node.sys.nscd.enable
