#
# Author:: Dennis Klein
# Author:: Victor Penso
#
# Copyright:: 2013, GSI HPC department
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

action :add do
  newkey = new_resource.key
  # Remove leading white-spaces
  newkey = newkey.gsub(/^ */,'')
  execute "Adding APT repository key" do
    command "echo '#{newkey}' | apt-key add - >/dev/null" 
  end
end

action :remove do
  keyid = new_resource.key
  # Remove leading white-spaces
  keyid = keyid.gsub(/^ */,'')
  execute "Remove APT repository key [#{keyid}]" do
    command "apt-key del #{keyid} >/dev/null"
    only_if "apt-key list | grep #{keyid} >/dev/null"
  end
end

