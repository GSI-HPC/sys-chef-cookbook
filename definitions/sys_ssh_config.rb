#
# Cookbook Name:: sys
# File:: definitions/sys_ssh_config.rb
#
# Copyright 2013-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

define :sys_ssh_config, :config => Hash.new do
  account = params[:name]

  # catch missing etc or local_etc ohai plugin:
  if node['etc']
    passwd = node['etc']['passwd'] || {}
  else
    passwd = {}
  end

  # does the user exists?
  if passwd.has_key? account
    if params[:config].empty?
      log("No SSH config attributes defined for account '#{account}'") do
        level :warn
      end
    else
      # path to the user SSH configuration
      dot_ssh = "#{passwd[account]['dir']}/.ssh"
      directory dot_ssh do
        owner account
        group passwd[account]['gid']
        mode "0700"
      end
      # path to the user keys file
      ssh_config = "#{dot_ssh}/config"
      template ssh_config do
        source 'user_ssh_config_generic.erb'
        owner account
        group passwd[account]['gid']
        cookbook 'sys'
        mode "0600"
        variables(
          :config => params[:config]
        )
      end
    end
  else
    log("Can't deploy SSH config: account '#{account}' missing") { level :warn }
  end

end
