#
# Copyright 2014-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
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

if Gem::Requirement.new('>= 12.5')
     .satisfied_by?(Gem::Version.new(Chef::VERSION))

  property :to, [Array, String],
           # turn Strings into Arrays for simplicity:
           coerce: proc { |t| t.is_a?(Array) ? t : t.split(/,\s*/) }
  property :aliases_file, String,  default: '/etc/aliases'

  default_action :add

  load_current_value do |new_resource|
    if ::File.exist?(new_resource.aliases_file)
      ::File.readlines(new_resource.aliases_file).each do |line|
        if line =~ /^#{new_resource.name}:(.*)/
          to $1.split(/,\s*/)
          break
        end
      end
    else
      current_value_does_not_exist!
    end
  end

  action :add do
    new_line = "#{new_resource.name}: "
    # man aliases:
    # > Use double quotes when the **name** contains any special characters
    # > such  as whitespace, `#', `:', or `@'
    new_line += new_resource.to.map do |e|
      e =~ /[:@#|\s]/ ? "\"#{e}\"" : e
    end.join(', ')

    aliases_file = Chef::Util::FileEdit.new(new_resource.aliases_file)
    if current_resource.to
      aliases_file.search_file_replace_line(/^#{new_resource.name}:/, new_line)
    else
      aliases_file.insert_line_if_no_match(/^#{new_resource.name}:/, new_line)
    end
    aliases_file.write_file

    execute "postalias #{new_resource.aliases_file}"
  end

  action :remove do
    aliases_file = Chef::Util::FileEdit.new(new_resource.aliases_file)
    aliases_file.search_file_delete_line(/^#{new_resource.name}:/)
    aliases_file.write_file

    execute "postalias #{new_resource.aliases_file}"
  end

else

  actions :add, :remove

  default_action :add

  attribute :name, :kind_of => String, :name_attribute => true,
            :required => true
  attribute :to,   :kind_of => [Array, String], :default => nil
  attribute :aliases_file, :kind_of => String,  :default => '/etc/aliases'

  attr_accessor :exists
end
