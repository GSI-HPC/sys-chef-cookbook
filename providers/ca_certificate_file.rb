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

base_path = '/usr/local/share/ca-certificates'
crt_pkg = 'ca-certificates'

action :add do
 
  name = new_resource.name
  path ="#{base_path}/#{name}"


  if node.run_context.resource_collection.select{ |e| e.name == crt_pkg }.empty?
    package crt_pkg
  end
  
  update = "Update CAs with new certificate: #{path}"
  execute update do
    command 'update-ca-certificates > /dev/null 2>&1'
    action :nothing
  end

  cookbook_file path do
    source new_resource.source
    mode '0644'
    notifies :run, "execute[#{update}]", :immediately
  end

end

action :remove do

  name = new_resource.name
  path ="#{base_path}/#{name}"

  if node.run_context.resource_collection.select{ |e| e.name == crt_pkg }.empty?
    package crt_pkg
  end
  
  update = "Update CAs after removing certificate: #{path}"

  execute update do
    command 'update-ca-certificates > /dev/null 2>&1'
    action :nothing
  end

  file path do
    action :delete
    notifies :run, "execute[#{update}]", :immediately
  end

end
