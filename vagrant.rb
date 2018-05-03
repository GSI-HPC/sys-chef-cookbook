Vagrant.configure(2) do |config|
    config.vm.provision "shell", inline: <<-SHELL
     sudo apt-get update
     sudo DEBIAN_FRONTEND=noninteractive apt-get -y install chef
  SHELL
end
