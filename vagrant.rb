Vagrant.configure(2) do |config|
  # exim4-base is required as MTA for sudo test
  config.vm.provision "shell", inline: <<-SHELL
     sudo apt-get -qq update
     sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install chef
     sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install exim4-base
  SHELL
end
