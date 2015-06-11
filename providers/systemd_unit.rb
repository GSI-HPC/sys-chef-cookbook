def whyrun_supported?
  true
end

use_inline_resources

action :create do
  converge_by("Create systemd unit #{absolute_path}:") do
    debug_log('systemd_unit_action_create')

    t = template absolute_path do
      source 'systemd_unit_generic.erb'
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
end

action :delete do
  converge_by("Delete systemd unit #{absolute_path}:") do
    debug_log('systemd_unit_action_delete')

    t = template "#{absolute_path}" do
      action :delete
    end

    execute 'systemctl daemon-reload' if t.updated_by_last_action?
  end
end

action :enable do
  converge_by("Enable systemd unit #{unit}:") do
    debug_log('systemd_unit_action_enable')
    unless state_or?([:enabled, :linked, :static])
      execute "systemctl enable #{unit}"
    end
  end
end

action :disable do
  converge_by("Disable systemd unit #{unit}:") do
    debug_log('systemd_unit_action_disable')
    execute "systemctl disable #{unit}" if state_or? [:enabled, :linked]
  end
end

action :start do
  converge_by("Start systemd unit #{unit}:") do
    debug_log('systemd_unit_action_start')
    execute "systemctl start #{unit}" unless is_active?
  end
end

action :stop do
  converge_by("Stop systemd unit #{unit}:") do
    debug_log('systemd_unit_action_stop')
    execute "systemctl stop #{unit}" if is_active?
  end
end

action :reload do
  converge_by("Reload systemd unit #{unit}:") do
    debug_log('systemd_unit_action_reload')
    execute "systemctl reload #{unit}" if is_active?
  end
end

action :restart do
  converge_by("Restart systemd unit #{unit}:") do
    debug_log('systemd_unit_action_restart')
    execute "systemctl restart #{unit}"
  end
end

action :mask do
  converge_by("Mask systemd unit #{unit}:") do
    debug_log('systemd_unit_action_mask')
    execute "systemctl mask #{unit}" unless state_or? [:masked]
  end
end

action :unmask do
  converge_by("Unmask systemd unit #{unit}:") do
    debug_log('systemd_unit_action_mask')
    execute "systemctl unmask #{unit}" if state_or? [:masked]
  end
end

def unit
  if new_resource.type.nil?
    name, type = new_resource.name.match(/^(.*)\.([^\.]*)$/).values_at(1,2)
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
