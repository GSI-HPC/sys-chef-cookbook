#
# Cookbook Name:: sys
# Recipe:: directory
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

unless node['sys']['file'].empty?
  node['sys']['file'].each do |name, config|
    file name do
      config.each do |key, value|
        if (key.to_sym == :content) && value.kind_of?(Array)
          send(key, value.join("\n"))
        elsif (key.to_sym == :notifies) && value.kind_of?(Array)
          send(key, *value)
        else
          send(key, value)
        end
      end
    end
  end
end
