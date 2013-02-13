#
# Copyright 2013, Victor Penso
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

define :sys_ssh_config, :config => Hash.new do
  account = params[:name]
  # does the user exists?
  if node.etc.passwd.has_key? account
    if params[:config].empty?
      log("Can't deploy SSH config: configuration for account [#{account}] missing") { level :warn }
    else
      # path to the user SSH configuration
      dot_ssh = "#{node.etc.passwd[account].dir}/.ssh"
      directory dot_ssh do
        owner account
        group node.etc.passwd[account].gid
        mode 0700
      end
      # path to the user keys file
      ssh_config = "#{dot_ssh}/config"
      template ssh_config do
        source 'user_ssh_config_generic.erb'
        owner account
        group node.etc.passwd[account].gid
        cookbook 'sys'
        mode 0600
        variables( 
          :path => node.etc.passwd[account].dir,
          :config => params[:config] 
        )
      end
    end
  else
    log("Can't deploy SSH config: account [#{account}] missing") { level :warn }
  end

end
