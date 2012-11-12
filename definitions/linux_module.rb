define :linux_module do
  execute "Enable module #{params[:name]} in /etc/modules" do
    command %Q[echo "#{params[:name]}" >> /etc/modules]
    not_if %Q[grep "^#{params[:name]}$" /etc/modules]
  end
  execute "Load module #{params[:name]}" do
    command "modprobe #{params[:name]}"
    not_if "lsmod | grep #{params[:name]}"
  end
end
