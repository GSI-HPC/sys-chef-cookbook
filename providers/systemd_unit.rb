#
# Cookbook Name:: sys
# Provider for custom resource sys_systemd_unit
#
# Copyright 2015-2016 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Dennis Klein   <d.klein@gsi.de>
#  Victor Penso   <v.penso@gsi.de>
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

use_inline_resources

action :create do
  debug_log('systemd_unit_action_create')

  directory new_resource.directory do
    mode '0755'
    owner new_resource.owner
    group new_resource.group
    recursive true
    action :create
  end

  t = template absolute_path do
    source 'systemd_unit_generic.erb'
    cookbook 'sys'
    mode new_resource.mode
    owner new_resource.owner
    group new_resource.group
    variables({
      path: absolute_path,
      config: new_resource.config
    })
    action :create
  end

  execute 'systemctl daemon-reload' if t.updated_by_last_action?
end

action :delete do
  debug_log('systemd_unit_action_delete')

  t = template absolute_path do
    action :delete
  end

  execute 'systemctl daemon-reload' if t.updated_by_last_action?
end

action :enable do
  debug_log('systemd_unit_action_enable')
  unless state_or?([:enabled, :linked, :static])
    execute "systemctl enable #{unit}"
  end
end

action :disable do
  debug_log('systemd_unit_action_disable')
  execute "systemctl disable #{unit}" if state_or? [:enabled, :linked]
end

action :start do
  debug_log('systemd_unit_action_start')
  execute "systemctl start #{unit}" unless is_active?
end

action :stop do
  debug_log('systemd_unit_action_stop')
  execute "systemctl stop #{unit}" if is_active?
end

action :reload do
  debug_log('systemd_unit_action_reload')
  execute "systemctl reload #{unit}" if is_active?
end

action :restart do
  debug_log('systemd_unit_action_restart')
  execute "systemctl restart #{unit}"
end

action :mask do
  debug_log('systemd_unit_action_mask')
  execute "systemctl mask #{unit}" unless state_or? [:masked]
end

action :unmask do
  debug_log('systemd_unit_action_mask')
  execute "systemctl unmask #{unit}" if state_or? [:masked]
end

def unit
  if new_resource.type.nil?
    if new_resource.name.match(/^(.*)\.(.*?)$/)
      name = Regexp.last_match(1)
      type = Regexp.last_match(2)
    else
      # assume type service if not explicitly given:
      name = new_resource.name
      type = 'service'
    end
  else
    name = new_resource.name
    type = new_resource.type
  end
  "#{name}.#{type}"
end

def absolute_path
  "#{new_resource.directory}/#{unit}"
end

def debug_log(prefix)
  Chef::Log.debug "#{prefix}: name = #{new_resource.name.inspect}"
  Chef::Log.debug "#{prefix}: type = #{new_resource.type.inspect}"
  Chef::Log.debug "#{prefix}: directory = #{new_resource.directory.inspect}"
  Chef::Log.debug "#{prefix}: mode = #{new_resource.mode.inspect}"
  Chef::Log.debug "#{prefix}: owner = #{new_resource.owner.inspect}"
  Chef::Log.debug "#{prefix}: group = #{new_resource.group.inspect}"
  Chef::Log.debug "#{prefix}: config = #{new_resource.config.inspect}"
end

def is_enabled(states)
  cmdStr = "systemctl is-enabled #{unit}"
  cmd = Mixlib::ShellOut.new(cmdStr)
  cmd.run_command
  res = {}
  states.each do |state|
    res[state] = (state.to_s == cmd.stdout.chomp)
  end
  res
end

def state_and?(states)
  is_enabled(states).values.inject(true) { |fold, state| fold && state }
end

def state_or?(states)
  is_enabled(states).values.inject(false) { |fold, state| fold || state }
end

def is_active?
  cmdStr = "systemctl is-active #{unit} --quiet"
  cmd = Mixlib::ShellOut.new(cmdStr)
  cmd.run_command
  cmd.exitstatus == 0
end

def is_failed?
  cmdStr = "systemctl is-failed #{unit} --quiet"
  cmd = Mixlib::ShellOut.new(cmdStr)
  cmd.run_command
  cmd.exitstatus == 0
end
