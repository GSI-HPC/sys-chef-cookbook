#
# Cookbook Name:: sys
# Recipe:: fail2ban
#
# Copyright 2017-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
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

return unless node['sys']['fail2ban']

package 'fail2ban'

service 'fail2ban' do
  action [:start, :enable]
  supports reload: true
end

template '/etc/fail2ban/jail.local' do
  helpers(Sys::Harry)
  source 'harry.erb'
  variables(config: node['sys']['fail2ban']['jail.local'])
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[fail2ban]'
  only_if { node['sys']['fail2ban']['jail.local'] }
end

if node['sys']['fail2ban']['logtarget'] == 'syslog'
  file '/etc/fail2ban/fail2ban.local' do
    content "[Definition]\nlogtarget = SYSLOG\n"
    mode '0644'
    owner 'root'
    group 'root'
    notifies :restart, 'service[fail2ban]'
  end

  # if you use an alternative logtarget (e.g. SYSLOG) thus not using
  # /var/log/fail2ban.log you should divert logrotate configuration into
  # a disabled state:
  execute 'dpkg-divert --rename' \
          ' --divert /etc/logrotate.d/fail2ban.diverted_by_chef' \
          ' /etc/logrotate.d/fail2ban' do
    not_if { File.exist? '/etc/logrotate.d/fail2ban.diverted_by_chef' }
  end
end
