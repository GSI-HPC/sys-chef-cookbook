#
# Cookbook Name:: sys
# Recipe:: script
#
# Author:: Victor Penso
#
# Copyright:: 2015, GSI HPC Department
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

unless node['sys']['script'].empty?
  node['sys']['script'].each do |name, config|
    script name do
      config.each do |key, value|
        if (key.to_sym == :code) && value.kind_of?(Array)
          send(key, value.join("\n"))
        else
          send(key, value)
        end
      end
    end
  end
end
