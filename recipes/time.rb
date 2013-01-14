#
# Cookbook Name:: sys
# Recipe:: time
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

timezone = node.sys.time.zone

unless timezone.empty?

  package 'tzdata'
  
  configure = "Configuring timezone to #{timezone}"
  
  file '/etc/timezone' do
    content "#{timezone}\n"
    mode 644
    notifies :run, "execute[#{configure}]"
  end
  
  execute configure do
    action :nothing
    command 'dpkg-reconfigure -f noninteractive tzdata'
  end

end

time_servers = node.sys.time.servers

unless time_servers.empty?

  package 'ntpdate'
  package 'ntp'
  service 'ntp'

  template '/etc/ntp.conf' do
    source 'etc_ntp.conf.erb'
    variables :servers => time_servers
    notifies :restart, "service[ntp]"
  end

end
