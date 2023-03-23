#
# Cookbook Name:: sys
# Recipe:: nsswitch
#
# Copyright 2013-2023 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

defaults = {
  passwd:    'files',
  group:     'files',
  shadow:    'files',
  gshadow:   'files',
  hosts:     ['files', 'dns'],
  networks:  'files',
  protocols: 'files',
  services:  'files',
  ethers:    'files',
  rpc:       'files',
}

# turn hash keys into Strings before merging to avoid dupes:
config = defaults.map { |k,v| [k.to_s, v] }.to_h

# merge defaults and node attributes
config.merge!(node['sys']['nsswitch']) do |_k,v1,v2|
  # make sure no empty values end up in the config:
  v2 || v1
end

if Gem::Requirement.new('>= 12.15')
    .satisfied_by?(Gem::Version.new(Chef::VERSION))

  # Use the custom resource if the chef version is new enough
  config.each do |db, srcs|
    Array(srcs).each_with_index do |src, i|
      sys_nsswitch db do
        source src
        priority 10*i
      end
    end
  end
elsif ! node['sys']['nsswitch'].empty?
  template "/etc/nsswitch.conf" do
    source "etc_nsswitch.conf.erb"
    mode '0644'
    variables(
      config: config
    )
  end
end
