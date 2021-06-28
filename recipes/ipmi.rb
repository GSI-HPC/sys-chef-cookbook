#
# Cookbook Name:: sys
# Recipe:: ipmi
#
# Copyright 2015-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matteo Dessalvi    <m.dessalvi@gsi.de>
#  Christopher Huhn   <c.huhn@gsi.de>
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
# IPMI related stuff
#

if node['sys']['ipmi']['install_packages'] ||
   ! node['sys']['ipmi']['overheat_protection'].empty?

  # Install the packages needed to configure/grab data from the IPMI cards:

  # Install the command line tool to access BMC data:
  package 'ipmitool'

  # Tools used by the supplied IPMI Ohai plugin (bmc-config):
  case node['platform_family']
  when 'debian'
    package 'freeipmi-tools'
  when 'rhel'
    package 'freeipmi'
  end

  # configure IPMI overheat protection:
  cookbook_file '/usr/local/sbin/ipmi-setup-overheat-protection' do
    source 'scripts/ipmi-setup-overheat-protection'
    mode 0o0755
  end

  if node['sys']['ipmi']['overheat_protection']['enable']

    # this data structure will be filled by IPMI ohai plugin
    #  (files/default/ohai_plugins/ipmi.rb)
    if node['ipmi'] and node['ipmi']['pef-config']

      cmd = '/usr/local/sbin/ipmi-setup-overheat-protection'
      cmd += " -w #{node['sys']['ipmi']['overheat_protection']['warn_threshold']}" if
        node['sys']['ipmi']['overheat_protection']['warn_threshold']
      cmd += " -c #{node['sys']['ipmi']['overheat_protection']['crit_threshold']}" if
        node['sys']['ipmi']['overheat_protection']['crit_threshold']

      execute 'Setup IPMI Overheat Protection' do
        command cmd
        # only run if no such filter already exists:
        only_if {
          node['ipmi']['pef-config'].select{ |k,v|
            k =~ /Event_Filter_(\d+)/ and
              v['Enable_Filter'] == 'Yes' and
              v['Event_Filter_Action_Power_Off'] == 'Yes' and
              v['Sensor_Type'] == 'Temperature'
          }.empty?
        }
        # don't abort, might converge only later:
        ignore_failure true
      end
    end

  end
end
