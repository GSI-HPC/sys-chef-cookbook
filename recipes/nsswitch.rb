#
# Cookbook Name:: sys
# Recipe:: nsswitch
#
# Copyright 2013-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Victor Penso       <v.penso@gsi.de>
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

# do nothing until requested
return if node['sys']['nsswitch'].empty?

sys_nsswitch_config 'default'

sys_nsswitch 'passwd' do
  sources ['compat']
end

sys_nsswitch 'group' do
  sources ['compat']
end

sys_nsswitch 'shadow' do
  sources ['compat']
end

sys_nsswitch 'gshadow' do
  sources ['files']
end

sys_nsswitch 'hosts' do
  sources ['files', 'dns']
end

sys_nsswitch 'networks' do
  sources ['files']
end

sys_nsswitch 'protocols' do
  sources ['db', 'files']
end

sys_nsswitch 'services' do
  sources ['db', 'files']
end

sys_nsswitch 'ethers' do
  sources ['db', 'files']
end

sys_nsswitch 'rpc' do
  sources ['db', 'files']
end

#sys_nsswitch 'netgroup' do
#  sources ['nis']
#end
