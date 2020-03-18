Vagrant.configure(2) do |config|
  # additional tools required for integration tests:
  config.vm.provision "shell", inline: <<-SHELL
    sudo yum -y install mailx postfix
    sudo systemctl start postfix
  SHELL
end
