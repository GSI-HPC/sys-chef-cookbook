#
# Cookbook Name:: sys
# File:: libraries/sys_harry.rb
#
# Copyright 2016-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch   <m.pausch@gsi.de>
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

module Sys
  module Harry

    def generate_harry_config(sections, indent=1, flags={})
      if flags[:sections].nil?
        flags[:sections] = true
      end

      unless flags[:indentation]
        flags[:indentation] = ''
        8.times{flags[:indentation] << ' '}
      end

      flags[:separator] ||= '='
      flags[:separator]

      if flags[:spaces_around_separator].nil?
        flags[:spaces_around_separator] = true
      end

      if flags[:alignment].nil?
        flags[:alignment] = true
      end

      if flags[:separator].length == 0
        flags[:separator] = ' '
      end

      if flags[:spaces_around_separator]
        flags[:separator].prepend(' ') << ' '
      end

      # Should not be set by user
      flags[:align] = ''
      file = ''
      sections.each do |name, section|
        file << "[#{name}]\n" if flags[:sections]
        max_key_length = section.keys.max_by {|e| e.length}.length
        section.each do |k, v|
          flags[:align] = ''
          if flags[:alignment]
            (max_key_length - k.length).times { flags[:align] << ' '}
          end
          render_harry_config(file, k, v, indent, flags)
        end
        file << "\n"
      end
      return file.strip
    end

    def render_harry_config(config, key, value, indent, flags)
      indentation = ''
      indent.times { indentation << flags[:indentation] }
      case value
      when Array
        value.each do |elt|
          render_harry_config(config, key, elt, indent, flags)
        end
      when Hash
        max_key_length = value.keys.max_by {|e| e.length}.length

        # Strictly speaking, flags[:align] should not be reset, but
        # that yields slightly less readable config-files
        flags[:align] = ''
        config << "#{indentation}#{key}#{flags[:align]}#{flags[:separator]}{\n"
        value.each do |k, v|
          flags[:align] = ''
          if flags[:alignment]
            (max_key_length - k.length).times { flags[:align] << ' '}
          end
          render_harry_config(config, k, v, indent + 1, flags)
        end
        config << "#{indentation}}\n"
      else
        config << "#{indentation}#{key}#{flags[:align]}#{flags[:separator]}#{value}\n"
      end
    end
  end
end
