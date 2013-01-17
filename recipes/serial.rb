#
# Cookbook Name:: sys
# Recipe:: serial
#
# Copyright 2012, Victor Penso
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

if node.sys.serial.port > 0

  port = node.sys.serial.port
  speed = node.sys.serial.speed

  template '/etc/inittab' do
    source 'etc_inittab.erb'
    variables :console => "s#{port}:2345:respawn:/sbin/getty -L #{speed} ttyS#{port} vt102"
  end

  # add the serial console to the grub boot configuration
  node.default[:sys][:boot][:params] << "console=tt1"
  node.default[:sys][:boot][:params] << "console=ttyS#{port},#{speed}n8"
  node.default[:sys][:boot][:config]['GRUB_SERIAL_COMMAND'] =
    "serial --speed=#{speed} --unit=#{port} --word=8 --parity=no --stop=1"

end
