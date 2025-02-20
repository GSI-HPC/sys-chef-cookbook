#
# Cookbook:: sys
# Helper library class
#
# Copyright:: 2015-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Dennis Klein      <d.klein@gsi.de>
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

    # where to store certificates and keys?
    def pki_base_path
      case node['platform_family']
      when 'rhel'
        '/etc/pki/tls'
      else
        '/etc/ssl'
      end
    end

    # Detect installed systemd
    def systemd_installed?
      case platform_family
      when 'rhel'
        true # systemd since RHEL7
      when 'debian'
        cmd = Mixlib::ShellOut.new('dpkg -s systemd-sysv')
        cmd.run_command
        cmd.exitstatus == 0
      end
    end

    # Detect active systemd instance
    def systemd_active?
      cmd = Mixlib::ShellOut.new('cat /proc/1/comm')
      cmd.run_command
      cmd.stdout.chomp == 'systemd'
    end
  end
end

Chef::Recipe.include(Sys::Helper)
Chef::Mixin::Template::TemplateContext.include(Sys::Helper)
