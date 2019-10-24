#
# Copyright 2014 - 2019, GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
# Authors:
#   Dennis Klein
#   Christopher Huhn
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

property :to, [Array, String],
         # turn Strings into Arrays for simplicity:
         coerce: proc { |t| t.is_a?(String) ? [t] : t }
property :aliases_file, String,  default: '/etc/aliases'

default_action :add

action :add do
  new_line = "#{new_resource.name}: "
  new_line += new_resource.to.map do |e|
    e =~ /[:@#|]/ ? "\"#{e}\"" : e
  end.join(', ')

  replace_or_add "alias for #{new_resource.name}" do
    path    new_resource.aliases_file
    pattern "^#{new_resource.name}:.*"
    line    new_line
    backup  true        if respond_to?(:backup)
    ignore_missing true if respond_to?(:ignore_missing)
  end
end

action :remove do
  delete_lines "alias for #{new_resource.name}" do
    path    new_resource.aliases_file
    pattern "^#{new_resource.name}:.*"
    only_if { ::File.exist?(new_resource.aliases_file) }
  end
end
