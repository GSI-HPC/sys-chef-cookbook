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

path = '/etc/apt/preferences.d'
apt_update = 'apt-get -qq update'

action :set do
  execute apt_update do
    action :nothing
  end
  template "#{path}/#{new_resource.name}" do
    source 'etc_apt_preferences.d_generic.erb'
    mode "0644"
    variables(
      :name => new_resource.name,
      :package => new_resource.package,
      :pin => new_resource.pin,
      :priority => new_resource.priority
    )
    cookbook "sys"
    notifies :run, "execute[#{apt_update}]", :immediately
  end
end

action :remove do
  execute apt_update do
    action :nothing
  end
  file "#{path}/#{new_resource.name}" do
    action :delete
    notifies :run, "execute[#{apt_update}]", :immediately
  end
end
