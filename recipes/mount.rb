# -*- coding: utf-8 -*-
#
# Cookbook Name:: sys
# Recipe:: resolv
#
# Author:: Victor Penso
#
# Copyright:: 2014, GSI Helmholtzzentrum für Schwerionenforschung GmbH
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

unless node['sys']['mount'].empty?

  # Make sure to install NFS support if it is required
  # by the configuration.
  nfs_required = false
  node['sys']['mount'].each_value do |config|
    if config.has_key? :fstype
      nfs_required = true if config[:fstype] == 'nfs'
    end
  end
  package 'nfs-common' if nfs_required

  node['sys']['mount'].each do |path,config|

    # Make sure the mount point exists
    directory path do
      recursive true
    end
    # Call the mount resource
    mount path do
      # Pass all configuration options to the mount resource
      config.each do |key,value|
        case key.to_s
        when 'provider'
          send(key, Module.const_get(value))
        else
          send(key, value)
        end
      end
    end
  end

end
