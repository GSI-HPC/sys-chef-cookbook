#
# Cookbook Name:: sys
# Recipe:: autofs
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

unless node.sys.autofs.maps.empty?

  package 'autofs'

  template '/etc/auto.master' do
    source 'etc_auto.master.erb'
    variables(
      :maps => node.sys.autofs.maps
    )
    notifies :reload, 'service[autofs]'
  end

  #  node.sys.autofs.maps.each_key do |path|
  #    directory path do
  #      recursive true
  #    end
  #  end

  service 'autofs' do
    supports :restart => true, :reload => true
  end

end
