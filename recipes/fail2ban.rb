#
# Cookbook Name:: sys
# Recipe:: fail2ban
#
# Copyright 2017, GSI HPC department
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

if node['sys']['fail2ban']

  package 'fail2ban'

  service 'fail2ban' do
    action [:start, :enable]
    supports reload: true
  end

  file '/etc/fail2ban/jail.local' do
    content "[DEFAULT]\nbanaction = nftables"
    mode '0644'
    owner 'root'
    group 'root'
    notifies :restart, 'service[fail2ban]'
  end

  file '/etc/fail2ban/fail2ban.local' do
    content "[DEFAULT]\nlogtarget = SYSLOG"
    mode '0644'
    owner 'root'
    group 'root'
    notifies :restart, 'service[fail2ban]'
  end
end
