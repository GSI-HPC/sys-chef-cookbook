#
# Cookbook Name:: gsi-desktop
# Recipe:: inuxlogo
#
# Copyright 2016-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
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

#
# activate linuxlogo on systemd nodes, cf. https://bugs.debian.org/750781
#

return unless node['sys']['linuxlogo']

package 'linuxlogo'

Chef::Recipe.include(Sys::Helper)

if systemd_installed?

  include_recipe 'sys::systemd'

  directory '/etc/systemd/system/getty@.service.d'

  file '/etc/systemd/system/getty@.service.d/linuxlogo.conf' do
    content <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noclear -f /etc/issue.linuxlogo %I $TERM
EOF
    # for linuxlogo on tty2..6:
    notifies :run, 'execute[sys-systemd-reload]', :immediately
    notifies :restart, 'service[getty@tty1]'
  end

  # for linuxlogo on tty1
  service 'getty@tty1'
end
