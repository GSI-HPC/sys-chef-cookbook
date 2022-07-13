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

defaults = {
  passwd:    'compat',
  group:     'compat',
  shadow:    'compat',
  gshadow:   'files',
  hosts:     ['files', 'dns'],
  networks:  'files',
  protocols: ['db', 'files'],
  services:  ['db', 'files'],
  ethers:    ['db', 'files'],
  rpc:       ['db', 'files'],
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

  sys_nsswitch_config 'default' do
    action :nothing
  end

  # Use the LWRP if the chef version is new enough
  config.each do |db, srcs|
    sys_nsswitch db do
      sources srcs
    end
  end
else
  template "/etc/nsswitch.conf" do
    source "etc_nsswitch.conf.erb"
    mode '0644'
    variables(
      config: config
    )
  end
end
