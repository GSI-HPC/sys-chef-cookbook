#
# Cookbook Name:: sys
# Recipe:: route
#
# Copyright 2014, GSI HPC Department
#
# Author:: Victor Penso
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

unless node['sys']['route'].empty?
  node['sys']['route'].each_pair do |target,config|
    # Add a route for each target by default
    act = :add
    act = :delete if config[:delete]
    # At least a gateway is required
    unless config.has_key? :gateway
      log "No gateway defined for target #{target}" do level :warn end
      next
    end
    route target do
      gateway config[:gateway]
      netmask config[:netmask] if config.has_key? :netmask
      device config[:device] if config.has_key? :device
      action act.to_sym
    end
  end
end
