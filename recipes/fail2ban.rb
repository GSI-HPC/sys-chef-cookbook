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

  jail_local = { }

  jail_local['DEFAULT'] = {
    destemail: node['sys']['fail2ban']['mailto'] || 'root@localhost'
  }

  jails = node['sys']['fail2ban']['jails'] || {}

  jails.each do |jail, conf|
    # read jails config from node attribute, may be nil
    jail_local[jail] = conf || {}

    # default to enable the given jail
    jail_local[jail]['enabled'] = conf['enabled'] || true
  end

  # FIXME: for Stretch this should go to /etc/fail2ban/jail.d/bla.conf
  template '/etc/fail2ban/jail.local' do
    source 'etc_fail2ban_jail.local.erb'
    variables(
      config: jail_local
    )
  end
end
