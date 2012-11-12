
_command = "sync; sync; shutdown"

action :reboot do
  execute "Reboot" do
    command %Q[#{_command} -r #{new_resource.time} "#{new_resource.message}\n"]
  end
end

action :shutdown do
  execute "Shutdown" do
    command %Q[#{_command} -h #{new_resource.time} "#{new_resource.message}\n" ]
  end
end
