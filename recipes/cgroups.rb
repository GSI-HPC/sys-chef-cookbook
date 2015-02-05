#
# Cookbook Name:: sys
# Recipe:: cgroups
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

unless node['sys']['cgroups']['path'].empty?

  package 'cgroup-bin'

  # flag indicating if a configured subsystem mount is missing
  run_config_cgroups = false

  # list of subsystems to deploy
  subsystems = Array.new

  node['sys']['cgroups']['subsys'].each do |subsys|
    # add subsystem to list
    path = "#{node['sys']['cgroups']['path']}/#{subsys}"
    subsystems << "#{subsys} = #{path}"
    # check if the mount is present already
    `grep " #{path} " /proc/mounts 1>-`
    # if not trigger configuration
    run_config_cgroups = true unless $?.success?
  end

  # Mount all configured subsystems
  config_cgroups = "Loading cgroups configuration"
  execute config_cgroups do
    command "cgclear; cgconfigparser -l /etc/cgconfig.conf"
    only_if do ::File.exists? '/etc/cgconfig.conf' and run_config_cgroups end
  end

  template '/etc/cgconfig.conf' do
    source 'etc_cgconfig.conf.erb'
    mode "0644"
    variables(
      :subsys => subsystems
    )
    notifies :run, "execute[#{config_cgroups}]", :immediately
  end

end
