#
# Cookbook Name:: sys
# Vagrant setup for test-kitchen
#
# Copyright 2018-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
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

Vagrant.configure(2) do |config|
  # install the Debian-provided Chef package
  # exim4-base is required as MTA for sudo test
  config.vm.provision 'shell', inline: <<-SHELL
     sudo apt-get -qq update
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install ruby
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install chef
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install exim4-base
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install mailutils
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install shellcheck
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install snmp
     # for sys_ssh_authorize test:
     sudo mkdir /home/mchammer
     sudo chattr +i /home/mchammer   # can't touch this
     sudo gem install chef-vault --version '< 4'
     # for testing recipe rsyslog
     test -d /etc/rsyslog.d || sudo mkdir /etc/rsyslog.d
     sudo touch /etc/rsyslog.d/loghost.conf
     # create a dummy kerberos keytab:
     sudo touch /etc/krb5.keytab
  SHELL

  # configure proxy if required:
  if Vagrant.has_plugin?('vagrant-proxyconf')
    config.proxy.http     = 'http://proxy.gsi.de:3128/'
    config.proxy.https    = 'http://proxy.gsi.de:3128/'
    config.proxy.no_proxy = 'localhost,127.0.0.1,.gsi.de'
  end
end
