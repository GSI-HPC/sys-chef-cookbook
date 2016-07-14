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

base_path = '/etc/apt/preferences.d'

action :set do

  name = new_resource.name
  path = "#{base_path}/#{name}"

  update = "Update APT with new perferences: #{path}"
  execute update do
    command 'apt-get -qq update'
    action :nothing
  end

  template path do
    source 'etc_apt_preferences.d_generic.erb'
    mode "0644"
    variables(
      :name => name,
      :package => new_resource.package,
      :pin => new_resource.pin,
      :priority => new_resource.priority
    )
    cookbook "sys"
    notifies :run, "execute[#{update}]", :immediately
  end

  # superseded by use_inline_resources
  #new_resource.updated_by_last_action(true)
end

action :remove do

  name = new_resource.name
  path = "#{base_path}/#{name}"

  update = "Update APT after removing perferences: #{path}"
  execute update do
    command 'apt-get -qq update'
    action :nothing
  end

  file path do
    action :delete
    notifies :run, "execute[#{update}]", :immediately
  end

  # superseded by use_inline_resources
  #new_resource.updated_by_last_action(true)
end
