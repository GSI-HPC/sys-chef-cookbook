#
# Cookbook Name:: nsswitch-test
# Recipe:: default
#
# Copyright 2013-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch    <m.pausch@gsi.de>
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

include_recipe 'sys::nsswitch'

if Gem::Requirement.new('>= 12.15')
    .satisfied_by?(Gem::Version.new(Chef::VERSION))

  # renders to 'string: source'
  sys_nsswitch 'string' do
    source 'source'
  end

  sys_nsswitch 'merge' do
    source 'merge10a'
  end

  sys_nsswitch 'merge' do
    source 'merge20a'
    priority 20
  end
  # Adds merge20b to previous merge20a
  # Adds merge10b to previous merge10a
  sys_nsswitch 'merge' do
    source 'merge10b'
  end

  sys_nsswitch 'merge' do
    source 'merge20b'
    priority 20
  end

  sys_nsswitch 'merge' do
    source 'merge30'
    priority 30
  end

  sys_nsswitch 'merge' do
    source 'merge40'
    priority 40
  end

  # should yield `passwd: files ldap`
  sys_nsswitch 'passwd' do
    sources 'ldap'
    priority 20
  end

  # should yield `passwd: ldap files`, because priority of files will be 30 insted of 10
  sys_nsswitch 'group' do
    source 'ldap'
    priority 20
  end

  sys_nsswitch 'group' do
    source 'files'
    priority 30
  end
end
