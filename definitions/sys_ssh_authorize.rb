#
# Copyright 2012, Victor Penso
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
    # does the user exists?  
    if node.etc.passwd.has_key?(account) or node[:sys][:accounts].has_key?(account)
      if params[:keys].empty?
        raise "key(s) missing for account [#{account}]"
      else
        if node[:etc][:passwd].has_key?(account)
          # path to the user SSH configuration
          dot_ssh = "#{node.etc.passwd[account].dir}/.ssh"
          gid     = node.etc.passwd[account].gid
        elsif node[:sys][:accounts].has_key?(account)
          dot_ssh = "#{node[:sys][:accounts][account][:home]}/.ssh"
          gid     = node[:sys][:accounts][account][:gid]
        else
          raise "#{account} has no home dir"
        end
        directory dot_ssh do
          owner account
          group gid if gid
          mode 0700
        end
        # path to the user keys file
        authorized_keys = "#{dot_ssh}/authorized_keys"
        # overwrite deviating keys
        if params[:managed]
          file "Deploying SSH keys for account [#{account}]" do
            path authorized_keys
            content params[:keys].join("\n") << "\n"
          end
          # append keys if missing
        else
          params[:keys].each do |key|
            execute "Deploying SSH authorized key for account [#{account}]" do
              command %[echo "#{key}" >> #{authorized_keys}]
              # the key is a string not a regex!
            not_if %Q[grep -q -F "#{key}" #{authorized_keys}]
            end
          end
        end
        #the file needs to have right ownership and permissions
        file authorized_keys do
          owner account
          group gid if gid
          mode 0644
        end
      end
    else
    log("Can't deploy SSH keys: account [#{account}] missing") { level :warn }
    end
  rescue Exception => e
    log("Can't deploy SSH keys: " + e.to_s) { level :error }
  end
end
