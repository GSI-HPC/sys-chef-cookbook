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

define :sys_sudo do
  name = params[:name]
  users = {}

  params[:users].each_pair do |user_alias, user_list|
    # user names including dashes must be quoted:
    users[user_alias] = user_list.map do |user|
      user.include?('-') ? "\"#{user}\"" : user
    end
  end

  template "/etc/sudoers.d/#{name}" do
    source 'etc_sudoers.d_generic.erb'
    owner  'root'
    group  'sudo'
    mode   0o0640
    cookbook "sys"
    variables(
      defaults: params[:defaults] || [],
      users:    users,
      hosts:    params[:hosts]    || {},
      commands: params[:commands] || {},
      rules:    params[:rules]
    )
  end
end
