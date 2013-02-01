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

define :sys_sudo, :users => Hash.new, :hosts => Hash.new, :commands => Hash.new, :rules => Array.new do
  name = params[:name]
  template "/etc/sudoers.d/#{name}" do
    source 'etc_sudoers.d_generic.erb'
    owner 'root'
    group 'root'
    mode 0440
    cookbook "sys"
    variables(
      :name => name,
      :users => params[:users],
      :hosts => params[:hosts],
      :commands => params[:commands],
      :rules => params[:rules]
    )
  end
end
