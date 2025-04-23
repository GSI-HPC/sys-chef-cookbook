#
# Cookbook:: sys
# Helper library class
#
# Copyright:: 2015-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Dennis Klein      <d.klein@gsi.de>
#  Matthias Pausch   <m.pausch@gsi.de>
#  Christopher Huhn  <c.huhn@gsi.de>
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
  module Helper

    # chef or cinc?
    def chef_product_name
      begin
        ChefUtils::Dist::Infra::SHORT
      rescue NameError
        'chef' # fallback if chef too old
      end
    end

    # return a meaningful numeric Debian version where
    #  the value for Testing or Unstable is 1) numeric and
    #  2) larger than any sensible Debian version number
    def debian_version
      return -1 unless on_debian?

      if node['platform_version'] =~ /^\d+(\.\d+)?$/
        node['platform_version'].to_f
      elsif node['platform_version'] =~ %r{^\w+/sid$}
        2**32 - 1.0
      else
        raise "Debian version could not be determined"
      end
    end

    def on_debian?
      node['platform'] == 'debian'
    end

    # Detect installed systemd
    def systemd_installed?
      cmd = Mixlib::ShellOut.new('dpkg -s systemd-sysv')
      cmd.run_command
      cmd.exitstatus == 0
    end

    # Detect active systemd instance
    def systemd_active?
      cmd = Mixlib::ShellOut.new('cat /proc/1/comm')
      cmd.run_command
      cmd.stdout.chomp == 'systemd'
    end

    # generate a standard header that can be used in template and file resources
    def template_header(comment = '#')
      header = "DO NOT CHANGE THIS FILE MANUALLY!\n\n" \
               "This file is managed by #{chef_product_name}.\n"\
               "Created by #{@cookbook_name}::#{@recipe_name}"
      # recipe_line and @template_name are only avaiable in TemplateContexts:
      header += " (line #{@recipe_line})" if @recipe_line
      header += " from template #{@template_name}" if @template_name
      header.gsub(/^ */, "#{comment} ")
    end
  end
end

Chef::Recipe.include(Sys::Helper)
Chef::Mixin::Template::TemplateContext.include(Sys::Helper)
Chef::Resource::File.include(Sys::Helper)
