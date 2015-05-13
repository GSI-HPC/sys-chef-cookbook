#
# Cookbook Name:: sys
# Recipe:: sdparm
#
# Author:: Dennis Klein <d.klein@gsi.de>
#
# Copyright:: 2015, GSI HPC Department
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

%w(set clear restore_default).each do |_action|
  node['sys']['sdparm'][_action].each do |_flag, disks|
    sys_sdparm disks.join(' ') do
      flag _flag
      action _action.to_sym
    end
  end
end
