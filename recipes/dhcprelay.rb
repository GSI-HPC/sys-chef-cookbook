#
# Cookbook Name:: sys
# Recipe:: dhcprelay
#
# Copyright 2012, GSI 
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

# recipe for DHCP relay setup
#  FIXME: not really suitable for sys - should go to a separate dhcp recipe

if node[:sys][:dhcprelay]

  # 'dhcp-helper' is a valid alternative here
  pkg = node[:sys][:dhcprelay][:package] || 'isc-dhcp-relay'

  package pkg
  
  servers    = node[:sys][:dhcprelay][:servers]
  interfaces = node[:sys][:dhcprelay][:interfaces]
  
  template "/etc/default/#{pkg}" do
    source "etc_default_#{pkg}.erb"
    variables ({
        :servers    => servers,
        :interfaces => interfaces
      })
    end
  
  service pkg do
    action [ :enable, :start ]
  end
end
