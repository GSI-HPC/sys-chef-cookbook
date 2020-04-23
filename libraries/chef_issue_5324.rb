#
# Cookbook Name:: sys
# Monkey patch for Chef::Provider::SystemdUnit
#
# needed to make `systemd_unit` work on Stretch
#  cf. https://github.com/chef/chef/issues/5324
#
# Copyright 2020 - GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

if Gem::Requirement.new('= 12.14.60')
     .satisfied_by?(Gem::Version.new(Chef::VERSION))
  class Chef
    class Provider
      class SystemdUnit
        # the systemd_unit provider will not run systemd-analyze verify <file>
        #  when systemd_analyze_path is nil
        def systemd_analyze_path
          Chef::Log.info('systemd_unit verification turned off by ' +
                         cookbook_name)
          nil
        end
      end
    end
  end
end
