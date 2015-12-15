use_inline_resources

action :set do
  install_sdparm

  todo = []
  load_sdparm.each do |disk, params|
    todo << disk if params[:value] == '0'
  end

  unless todo.empty?
    cmdStr = "sdparm --set=#{new_resource.flag} --save --quiet #{todo.join(' ')}"
    execute cmdStr do
      Chef::Log.debug "sdparm_action_set: #{cmdStr}"
      Chef::Log.info "Setting sdparm #{new_resource.flag} on #{todo.join(' ')}."
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info "#{new_resource} is already set - nothing to do."
  end
end

action :clear do
  install_sdparm

  todo = []
  load_sdparm.each do |disk, params|
    todo << disk if params[:value] == '1'
  end

  unless todo.empty?
    cmdStr = "sdparm --clear=#{new_resource.flag} --save --quiet #{todo.join(' ')}"
    execute cmdStr do
      Chef::Log.debug "sdparm_action_clear: #{cmdStr}"
      Chef::Log.info "Clearing sdparm #{new_resource.flag} on #{todo.join(' ')}."
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info "#{new_resource} is already cleared - nothing to do."
  end
end

action :restore_default do
  install_sdparm

  todo = []
  load_sdparm.each do |disk, params|
    if params[:value] != params[:default]
      todo << {
        disk: disk,
        value: params[:default]
      }
    end
  end

  todo.each do |item|
    method = item[:value] == '1' ? 'set' : 'clear'
    cmdStr = "sdparm --#{method}=#{new_resource.flag} --save --quiet #{item[:disk]}"
    execute cmdStr do
      Chef::Log.debug "sdparm_action_restore_default: #{cmdStr}"
      Chef::Log.info "Restoring default sdparm #{new_resource.flag} on #{item[:disk]}."
      new_resource.updated_by_last_action(true)
    end
  end

  Chef::Log.info "#{new_resource} is already in default state - nothing to do." if todo.empty?
end

def install_sdparm
  package 'sdparm'
end

def load_sdparm
  cmdStr = "sdparm --get=#{new_resource.flag} #{new_resource.disk}"
  cmd = Mixlib::ShellOut.new(cmdStr)
  cmd.run_command
  Chef::Log.debug "load_sdparm: #{cmdStr}"
  Chef::Log.debug "load_sdparm: #{cmd.stdout}"

  sdparm = {}
  cmd.stdout.scan(/(\S+):.*\n.*#{new_resource.flag}\s*(\S+).*def:\s*(\S+), sav:\s*(\S+)\]/) do |scan|
    disk, value, default, save = scan
    sdparm[disk] = {
      default: default,
      save: save,
      value: value
    }
  end

  Chef::Log.debug "load_sdparm: #{sdparm.inspect}"
  sdparm
end
