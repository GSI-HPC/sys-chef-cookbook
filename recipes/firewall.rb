#
# Cookbook Name:: sys
# Recipe:: firewall
#
# Copyright 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch (m.pausch@gsi.de)
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
# This code is an adjustment of https://github.com/sous-chefs/firewall
#

return unless node['sys']['firewall']['manage']
return unless Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

fw_action = node['sys']['firewall']['disable'] ? :disable : :install
firewall 'default' do
  action fw_action
end

firewall_rule 'allow loopback' do
  interface 'lo'
  protocol :none
  command :allow
  only_if { node['sys']['firewall']['allow_loopback'] }
end

firewall_rule 'allow icmp' do
  protocol :icmp
  command :allow
  only_if { node['sys']['firewall']['allow_icmp'] }
end

firewall_rule 'allow world to ssh' do
  port 22
  source '0.0.0.0/0'
  only_if { node['sys']['firewall']['allow_ssh'] }
end

# allow established connections
firewall_rule 'established' do
  stateful [:related, :established]
  protocol :none # explicitly don't specify protocol
  command :allow
  only_if { node['sys']['firewall']['allow_established'] }
end
