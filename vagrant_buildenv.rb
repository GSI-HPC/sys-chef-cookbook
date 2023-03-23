#
# Cookbook Name:: sys
# Vagrant setup for test-kitchen build environment
#
# Copyright 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install ruby-dev
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install libffi-dev
     sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y install build-essential
  SHELL
end
