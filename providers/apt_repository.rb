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

use_inline_resources

base_path = '/etc/apt/sources.list.d'

action :add do

  name = "#{new_resource.name}.list"
  path = "#{base_path}/#{name}"

  update = "Update APT with new source: #{path}"
  execute update do
    command 'apt-get -qq update'
    action :nothing
    ignore_failure true
  end

  template path do
    source 'etc_apt_sources.list.d_generic.erb'
    mode "0644"
    variables(
      :config => new_resource.config.gsub(/^ */,'')
    )
    cookbook "sys"
    notifies :run, "execute[#{update}]", :immediately
  end

  # automatically set by use_inline_resources
  #  if changes were made
  #new_resource.updated_by_last_action(true)
end

action :remove do

  name = "#{new_resource.name}.list"
  path = "#{base_path}/#{name}"

  update = "Update APT after removing source: #{path}"
  execute update do
    command 'apt-get -qq update'
    action :nothing
    ignore_failure true
  end

  file path do
    action :delete
    notifies :run, "execute[#{update}]", :immediately
  end

  # automatically set by use_inline_resources
  #  if changes were made
  #new_resource.updated_by_last_action(true)
end
