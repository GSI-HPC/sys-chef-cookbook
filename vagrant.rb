Vagrant.configure(2) do |config|
    config.vm.provision "shell", inline: <<-SHELL
     sudo apt-get -q update
     sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install chef
  SHELL
end
