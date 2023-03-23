#
# Cookbook Name:: sys
# Ohai plugin to collect sysctl information
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

Ohai.plugin(:Sysctl) do
  provides 'sysctl'

  collect_data(:default) do
    cmd = 'sysctl -a'
    settings = shell_out(cmd).stdout.scan(/^(.*) = (.*)$/)

    sysctl Mash.new
    settings.each do |key, value|
      # skip zero values to reduce space requirements
      next if value == '0'

      # split the sysctl key into components and create s nice data structure
      path = key.split('.')
      x = sysctl
      path[0..-2].each do |component|
        x[component] ||= Mash.new
        x = x[component]
      end
      x[path.last] = value
    end
  end
end
