#
# Cookbook Name:: sys
# Recipe:: time
#
# Copyright 2012-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn  <c.huhn@gsi.de>
#  Dennis Klein      <d.klein@gsi.de>
#  Matthias Pausch   <m.pausch@gsi.de>
#  Victor Penso      <v.penso@gsi.de>
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

timezone = node['sys']['time']['zone']

unless timezone.empty?

  package 'tzdata'

  configure = "Configuring timezone to #{timezone}"

  file '/etc/timezone' do
    content "#{timezone}\n"
    mode "644"
  end

  (area, zone) = timezone.split('/')

  # invoking dpkg-reconfigure only if neccessary is quite cumpersome:
  bash configure do
    code <<CMD
debconf-set-selections <<-DEBCONF:n
tzdata tzdata/Zones/#{area} select #{zone}
tzdata tzdata/Areas select #{area}
DEBCONF
dpkg-reconfigure -f noninteractive tzdata
CMD
    # TODO: writs and use Ohai provider for debconf data
    not_if <<TEST
      debconf-show tzdata |
         grep '^[* ] tzdata/Areas: #{area}$' &&
      debconf-show tzdata |
         grep "^[* ] tzdata/Zones/#{area}: #{zone}$"
TEST
  end

end

time_servers = node['sys']['time']['servers']

unless time_servers.empty?

  package 'ntpdate'
  package 'ntp'

  template '/etc/ntp.conf' do
    source 'etc_ntp.conf.erb'
    variables :servers => time_servers
    notifies :restart, "service[ntp]"
  end

  # Comments in systemctl-src say that update-rc.d does not provide
  # information wheter a service is enabled or not and always returns
  # false.  Work around that.
  actions = [:start]
  actions << :enable if Dir.glob('/etc/rc2.d/*ntp*').empty?

  service 'ntp' do
    action actions
    supports :status => true, :restart => true
  end
end
