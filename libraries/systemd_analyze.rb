#
# Cookbook Name:: sys
# File:: libraries/systemd_analyze.rb
#
# Copyright 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# systemd-analyze verify [..] fails if called inside a chroot
#  therefore the verification of systemd units does not work
#  we circumvent this by setting systemd_analyze_path to nil
#  which will make Chef::Resource::File::Verification::SystemdUnit.verify
#  unconditionally succeed
#

#
class Chef
  #
  class Resource
    #
    class File
      #
      class Verification
        #
        class SystemdUnit
          def inside_chroot?
            # device and inode number for / and /proc/1/root match
            #  unless we are inside a chroot:
            ::File.stat('/').dev != ::File.stat('/proc/1/root').dev ||
              ::File.stat('/').ino != ::File.stat('/proc/1/root').ino
          rescue Errno::ENOENT
            # /proc is not mounted -> assume we ere in a chroot
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