#
# Copyright 2014, Dennis Klein
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

action :add do
  new_resource.to(escape_value(new_resource.to))
  new_line = "#{new_resource.name}: #{new_resource.to}"

  if @current_resource.exists
    unless @current_resource.to == new_resource.to
      # Mail alias exists, but points to wrong value:
      #  * change alias value

      ruby_block 'SysMailAlias action :add : change alias value' do
        block do
          aliases_file = Chef::Util::FileEdit.new(new_resource.aliases_file)
          aliases_file.search_file_replace_line(alias_regexp, new_line)
          aliases_file.write_file
        end
      end

      new_resource.updated_by_last_action(true)
    end
  else
    # Mail alias does not exist:
    #  * create new aliases file, if missing
    #  * insert mail alias

    file "mail_alias #{new_resource.aliases_file}" do
      path new_resource.aliases_file
      action :create
      not_if { ::File.exist?(new_resource.aliases_file) }
    end

    ruby_block 'SysMailAlias action :add : insert alias' do
      block do
        aliases_file = Chef::Util::FileEdit.new(new_resource.aliases_file)
        aliases_file.insert_line_if_no_match(alias_regexp, new_line)
        aliases_file.write_file
      end
    end

    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  if @current_resource.exists
    # Mail alias exists:
    #  * delete the alias from aliases file

    ruby_block 'SysMailAlias action :remove : remove alias' do
      block do
        aliases_file = Chef::Util::FileEdit.new(new_resource.aliases_file)
        aliases_file.search_file_delete_line(alias_regexp, new_line)
        aliases_file.write_file
      end
    end

    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  @current_resource = Chef::Resource::SysMailAlias.new(new_resource.name)
  @current_resource.exists = false

  if ::File.exist? new_resource.aliases_file
    lines = ::File.readlines(new_resource.aliases_file).select { |line| line =~ /^#{@current_resource.name}:/ }
    unless lines.empty?
      @current_resource.to(lines.first.match(/:(.*)$/)[1].strip)
      @current_resource.exists = true
    end
  end

  @current_resource
end

def escape_value(value)
  if value =~ /[:@#|]/
    "\"#{value}\""
  else
    value
  end
end

def alias_regexp
  /^#{new_resource.name}:/
end
