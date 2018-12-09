#
# Cookbook Name:: sys
# Recipe:: resolv
#
# Copyright 2012 - 2018 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Victor Penso
#  Matthias Pausch
#  Christopher Huhn
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

return if node['sys']['resolv']['servers'].empty?

# From resolv.conf's man page:
# > The domain and search keywords are mutually exclusive.
# > If more than one instance of these keywords is present,
# > the last instance wins.
log 'domain+search' do
  message "'search' and 'domain' are mutually exclusive, the latter will be ignored"
  level   :info
  only_if { node['sys']['resolv'].key?('domain') &&
            node['sys']['resolv'].key?('search') }
end

log 'resolv.conf-symlink' do
  message "/etc/resolv.conf is a symlink - " +
          (node['sys']['resolv']['force'] ?
             'overwrite forced' : 'not touching it')
  level   :warn
  only_if { File.symlink?('/etc/resolv.conf') }
end

template '/etc/resolv.conf' do
  source 'etc_resolv.conf.erb'
  mode "0644"
  # don't edit the file /etc/resolv.conf might point to but the file itself
  manage_symlink_source false
  variables(
    servers: node['sys']['resolv']['servers'],
    domain:  node['sys']['resolv']['domain'],
    search:  node['sys']['resolv']['search'],
    options: node['sys']['resolv']['options'] || []
  )
  not_if do
    # -> managed by resolvconf/systemd-resolved:
    File.symlink?('/etc/resolv.conf') &&
      !node['sys']['resolv']['force']
  end
end
