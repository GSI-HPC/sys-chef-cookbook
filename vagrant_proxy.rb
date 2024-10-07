#
# Cookbook:: sys
# Vagrant proyx setup
#
# Copyright 2018-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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
  # configure proxy if required:
  if Vagrant.has_plugin?('vagrant-proxyconf')
    config.proxy.http     = 'http://proxy.gsi.de:3128/'
    config.proxy.https    = 'http://proxy.gsi.de:3128/'
    config.proxy.no_proxy = 'localhost,127.0.0.1,.gsi.de'
  end
end
