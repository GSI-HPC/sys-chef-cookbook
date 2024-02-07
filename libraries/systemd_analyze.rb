#
# Cookbook Name:: sys
# Library:: Monkey patch for Chef::Resource::File::Verification::SystemdUnit
#
# Copyright 2022-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
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

#
# systemd-analyze verify [..] fails if called inside a chroot
#  therefore the verification of systemd units does not work
#  we circumvent this by setting systemd_analyze_path to nil
#  which will make Chef::Resource::File::Verification::SystemdUnit.verify
#  unconditionally succeed
#

class Chef
  class Resource
    class File
      class Verification
        class SystemdUnit
          def inside_chroot?
            # device and inode number for / and /proc/1/root match
            #  unless we are inside a chroot:
            ::File.stat('/').dev != ::File.stat('/proc/1/root').dev ||
              ::File.stat('/').ino != ::File.stat('/proc/1/root').ino
          rescue Errno::ENOENT
            # /proc is not mounted -> assume we are in a chroot
            true
          end

          original_systemd_analyze_path = instance_method :systemd_analyze_path

          define_method(:systemd_analyze_path) do
            return if inside_chroot?

            original_systemd_analyze_path.bind(self).call
          end
        end
      end
    end
  end
end
