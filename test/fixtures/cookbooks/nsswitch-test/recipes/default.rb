#
# Cookbook Name:: sys
# Recipe:: nsswitch_test
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

  # coerces to {'string' => {'source' => 10}}
  # renders to 'string: source'
  sys_nsswitch 'string' do
    sources 'source'
  end

  # coerces {'hash' => {'prio20' => 20, 'prio10' => 10}}
  # renders to 'hash: prio10 prio20'
  sys_nsswitch 'hash' do
    sources ({
      'prio20' => 20,
      'prio10' => 10
    })
  end

  # coerces to {'array' => {array1 => 10, array2 => 20}}
  # renders to 'array: array1 array2
  sys_nsswitch 'array' do
    sources ['array1', 'array2']
  end

  # coerces to:
  # 'merge' => {
  #   'merge10a' => 10
  # }
  sys_nsswitch 'merge' do
    sources 'merge10a'
  end

  # coerces to:
  # 'merge' => {
  #   'merge20a' => 20
  # }
  sys_nsswitch 'merge' do
    sources ({'merge20a' => 20})
  end

  # coerces to:
  # 'merge' => {
  #   'merge10b' => 10,
  #   'merge20b' => 20,
  #   'merge30a' => 30,
  #   'merge40' => 40
  # }
  # overwrites previous merge20a with merge20
  # overwrites previous merge10a with merge10b
  sys_nsswitch 'merge' do
    sources ['merge10b', 'merge20b', 'merge30a', 'merge40']
  end

  # coerces to:
  # 'merge' => {
  #   'merge10c' => 10,
  #   'merge30b' => 30,
  #   'merge9' => 9,
  #   'merge50' => 50
  # }
  # merge overwrite previous merge10b with merge20
  # finally renders to:
  # merge:          merge9 merge10c merge20b merge30b merge40 merge50
  sys_nsswitch 'merge' do
    sources ({
      'merge10c' => 10,
      'merge30b' => 30,
      'merge9' => 9,
      'merge50' => 50
    })
  end
end
