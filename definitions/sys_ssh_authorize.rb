# Cookbook Name:: sys
# File:: definitions/sys_ssh_authorize.rb
#
# Copyright 2012-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Victor Penso       <v.penso@gsi.de>
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

define :sys_ssh_authorize, :keys => Array.new, :managed => false do
  account = params[:name]
  begin

    getent_passwd = shell_out("getent passwd #{params[:name]}")

    # Does the user exist?
    if node['etc']['passwd'].has_key?(account) ||
       node['sys']['accounts'].has_key?(account) ||
       (getent_passwd.exitstatus == 0)

      if params[:keys].empty?
        raise "key(s) missing for account [#{account}]"
      else
        if node['etc']['passwd'].has_key?(account)
          # path to the user SSH configuration
          dot_ssh = "#{node['etc']['passwd'][account]['dir']}/.ssh"
          gid     = node['etc']['passwd'][account]['gid']
        elsif node['sys']['accounts'].key?(account) &&
              node['sys']['accounts'][account].key?('home')
          dot_ssh = "#{node['sys']['accounts'][account]['home']}/.ssh"
          gid     = node['sys']['accounts'][account]['gid']
        elsif getent_passwd.exitstatus == 0
          parts = getent_passwd.stdout.split(':')
          dot_ssh = "#{parts[5]}/.ssh"
          gid     = parts[3].to_i
        else
          raise "can't determine location of ~/.ssh for #{account}"
        end

        unless File.directory?(File.dirname(dot_ssh))
          raise "#{account} has no home dir"
        end

        unless File.writable?(File.dirname(dot_ssh))
          raise "~#{account} is not writable (root_squash?)"
        end

        # Create the ~/.ssh directory if missing
        if node.run_context.resource_collection.select{ |e| e.name == dot_ssh }.empty? # ~FC023
          directory dot_ssh do
            owner account
            group gid if gid
            mode "0700"
          end
        end

        # path to the user keys file
        authorized_keys = "#{dot_ssh}/authorized_keys"
        # overwrite deviating keys
        if params[:managed]
          file "Deploying SSH keys for account #{account} to #{authorized_keys}" do
            path authorized_keys
            content params[:keys].join("\n") << "\n"
          end

        # Append SSH keys to authorized keys file if the file isn't managed
        else
          # Iterate over the key list
          params[:keys].each_index do |index|
            key = params[:keys][index]
            # Append the key unless existing already
            execute "Append SSH key #{index+1} for account #{account} to #{authorized_keys}" do
              command %[echo "#{key}" >> #{authorized_keys}]
              # The key is a string not a regex!
              not_if %Q[grep -q -F "#{key}" #{authorized_keys}]
            end
          end
        end

        #the file needs to have right ownership and permissions
        file authorized_keys do
          owner account
          group gid if gid
          mode "0644"
          only_if { node.run_context.resource_collection.select{ |e|
              e.name == authorized_keys }.empty? }
        end

      end
    else
      log "User account #{account} missing. SSH public key not deployed." do
        level :warn
      end
    end
  rescue StandardError => e
    log("Can't deploy SSH keys: " + e.to_s) { level :error }
  end
end
