#
# Cookbook Name:: sys
# Recipe:: java
#
# Copyright 2015 - 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Author: Christopher Huhn
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

return unless node['sys']['java']

jre_or_jdk = node['sys']['java']['install_jdk'] ? 'jdk' : 'jre'

package "default-#{jre_or_jdk}" do
  # this is openjdk 6 on Wheezy which is not supported by wheezy-lts
  not_if { node['lsb']['codename'] == 'wheezy' }
end

if node['sys']['java']['versions']
  node['sys']['java']['versions'].each do |v|
    package "openjdk-#{v}-#{jre_or_jdk}" do
      # installations from ...-backports may fail
      ignore_failure true
    end
  end
end

arch = node['debian']['architecture'] ||
       case node['kernel']['machine']
       when 'x86_64'
         'amd64'
       end

default_version = node['sys']['java']['default_version'] ||
                  node['sys']['java']['versions'].first

execute 'update-java-alternatives' do
  command "update-java-alternatives --set "\
          "java-1.#{default_version}.0-openjdk-#{arch}"
  # cf. http://bugs.debian.org/929105
  returns [0, 2]
  not_if { arch.nil? || default_version.nil? }
end
