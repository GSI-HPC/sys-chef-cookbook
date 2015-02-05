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

_command = "sync; sync; shutdown"

action :reboot do
  execute "Reboot" do
    command %Q[#{_command} -r #{new_resource.time} "#{new_resource.message}\n"]
  end

  new_resource.updated_by_last_action(true)
end

action :shutdown do
  execute "Shutdown" do
    command %Q[#{_command} -h #{new_resource.time} "#{new_resource.message}\n" ]
  end

  new_resource.updated_by_last_action(true)
end
