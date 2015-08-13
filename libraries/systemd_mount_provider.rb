#
# Author:: Caleb Tennis (<joshua@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc
# License:: Apache License, Version 2.0
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

require 'chef/provider/mount'
require 'chef/log'
require 'chef/mixin/shell_out'
require 'shellwords'

class Chef
  class Provider
    class Mount
      class SystemdMount < Chef::Provider::Mount::Mount
        include Chef::Mixin::ShellOut

        def initialize(new_resource, run_context)
          super
        end

        def enabled?
          unless @current_resource.enabled == true
            systemd_file = systemd_substitute(@new_resource.mount_point)
            if ::File.exist?("/etc/systemd/system/" + systemd_file)
              begin
                if shell_out!("systemctl is-enabled #{Shellwords.escape(systemd_file)}").exitstatus == 0
                  @current_resource.enabled(true)
                end
              rescue Mixlib::ShellOut::ShellCommandFailed, SystemCallError => e
                Chef::Log.debug e
              end
            end
          end
        end

        def enable_fs
          if @current_resource.enabled && mount_options_unchanged?
            Chef::Log.debug("#{@new_resource} is already enabled - nothing to do")
            return nil
          end

          if network_device?
            wanted_by = "remote-fs.target"
          else
            wanted_by = "local-fs.target"
          end

          options = @new_resource.options.nil? ? "defaults" : @new_resource.options.join(",")
          mp = @new_resource.mount_point
          type_entry = @new_resource.fstype == "auto" ? "" : "Type=#{@new_resource.fstype}\n"
          requires = options =~ /_netdev/ ? "Requires=network-online.target\nWants=systemd-networkd-wait-online.service\nAfter=network-online.target\n" : "\n"

          ::File.open("/etc/systemd/system/" + systemd_substitute(mp), "w") do |sm|
            sm.puts("[Unit]\nDescription=Mount for #{mp}\n#{requires}\n")
            sm.puts("[Install]\nWantedBy=#{wanted_by}\n\n")
            sm.puts("[Mount]\nWhat=#{device_systemd}\nWhere=#{mp}\n#{type_entry}Options=#{options}")
          end

          begin
            shell_out!("systemctl enable #{Shellwords.escape(systemd_substitute(mp))}")
          rescue Mixlib::ShellOut::ShellCommandFailed, SystemCallError => e
            Chef::Log.debug e
          end

          Chef::Log.debug("#{@new_resource} is enabled at #{mp}")
        end

        def disable_fs
          if @current_resource.enabled
            systemd_file = systemd_substitute(@new_resource.mount_point)
            if ::File.exist?("/etc/systemd/system/" + systemd_file)
              begin
                shell_out!("systemctl disable #{Shellwords.escape(systemd_file)}")
                ::File.unlink("/etc/systemd/system/" + systemd_file)
              rescue Mixlib::ShellOut::ShellCommandFailed, SystemCallError => e
                Chef::Log.debug e
              end
            end
          else
            Chef::Log.debug("#{@new_resource} is not enabled - nothing to do")
          end
        end

        private

        def systemd_substitute(filename)
          # systemd does some cleansing of device file names before writing them to .mount files.
          # 1. Leading and trailing slashes are removed.
          # 2. All other slashes (/) in the filename are changed to dashes (-)    
          #    e.g. /home/foo -> home-foo.mount
          # 3. Any original dashes or non-printable characters in the filename are changed to their C-style escaped equivalents:
          #    e.g. /home/asdf-jkl -> home-asdf\x2djkl.mount

          stripped_filename = filename[1..-1] if filename =~ /^\//
          stripped_filename = stripped_filename.chop if stripped_filename =~ /\/$/
          stripped_filename = stripped_filename.gsub('-', "\\x2d")
          stripped_filename = stripped_filename.gsub('/','-')
          stripped_filename + ".mount"
        end

        def device_systemd
          case @new_resource.device_type
          when :device
            @new_resource.device
          when :label
            "/dev/disk/by-label/#{@new_resource.device}"
          when :uuid
            "/dev/disk/by-uuid/#{@new_resource.device}"
          end
        end

      end
    end
  end
end
