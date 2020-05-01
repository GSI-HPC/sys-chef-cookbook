#
# Copyright 2014-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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
           coerce: proc { |t| Array(t) }
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
else
  actions :add, :remove

  default_action :add

  attribute :name, :kind_of => String, :name_attribute => true,
            :required => true
  attribute :to,   :kind_of => [Array, String], :default => nil
  attribute :aliases_file, :kind_of => String,  :default => '/etc/aliases'

  attr_accessor :exists
end
