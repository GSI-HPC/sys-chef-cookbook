#
# Cookbook Name:: sys
# Recipe:: kernel
#
# Copyright 2017, GSI HPC department
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

# Kernel installation related tasks
#
# - runtime parameters set via sysctl are managed bay the 'control' recipe
# - GRUB related tasks are handled by the 'boot' recipe

if node['sys']['kernel'] # don't break conventions in sys

  # Detect the CPU vendor
  cpu_vendor = case node['cpu']['0']['vendor_id']
               when 'GenuineIntel'
                 'intel'
               when 'AuthenticAMD'
                 'amd64'
               end

  mircocode_package = case node['platform_family']
                      when 'debian'
                        "#{cpu_vendor}-microcode"
                      when 'redhat'
                        'microcode_ctl'
                      end

  # install the CPU microcode updates cf. https://wiki.debian.org/Microcode
  #  when node['sys']['kernel']['install_microcode'] is set
  package mircocode_package do
    only_if { node['sys']['kernel']['install_microcode'] }
  end
end
