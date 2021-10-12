#
# Author:: Matthias Pausch (<m.pausch@gsi.de>)
# Cookbook:: sys
# Provider:: nsswitch
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
# Use nsswitch resource to configure a database like so
#
# nsswitch 'automount' do
#   sources ['files', 'ldap']
# end
#
#
# In case of conflict with other recipes, provide a sources as hash with priority as value:
#
# nsswitch 'automount' do
#   sources ['files', 'ldap']
# end
#
# is equal to
#
# nsswitch 'automount' do
#   sources {
#      10 => 'files',
#      20 => 'ldap',
#   }
# end
#
# And from another recipe:
#
# nsswitch 'automount_with_sssd' do
#   database 'automount'
#   sources {
#      10 => 'files',
#      20 => 'sssd',
#   }
# end
#
# This will result in
# automount: files sssd ldap

#unified_mode true

provides :nsswitch

property :database, String, name_property: true
property :sources, [String, Array, Hash]
property :notify_nsswitch_config, [true, false], default: true
property :merge, [true, false], default: true

action_class do
  def sources_to_hash(sources)
    return sources if sources.instance_of?(Hash)

    sources_as_hash = {}
    Array(sources).each_with_index do |s, i|
      sources_as_hash[s] = 10*(i + 1)
    end
    return sources_as_hash
  end
end

action :create do
  return unless new_resource.notify_nsswitch_config
  nsswitch_resource = new_resource
  nsswitch_resource.sources = sources_to_hash(nsswitch_resource.sources)
  with_run_context :root do
    edit_resource('sys_nsswitch_config', 'default') do
      config[database] ||= {}
      config[database].merge! nsswitch_resource.sources
    end
  end
end
