#
# Author:: Matthias Pausch (<m.pausch@gsi.de>)
# Cookbook:: sys
# Provider:: nsswitch_config
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
# Generate /etc/nsswitch.conf from nsswitch resources

# unified_mode true

provides :nsswitch_config

action_class do
  def create_content(config)
    content = ''
    config.each do |db, sources_hash|
      sorted_sources = sources_hash.keys.sort.inject([]) do |a, key|
        a << sources_hash[key]
      end
      content << "#{db}: "
      content << sorted_sources.join(' ')
    end
    "#{content}\n"
  end
end

property :filename, String, default: '/etc/nsswitch.conf'
property :mode, String, default: '0644'
property :owner, String, default: 'root'
property :group, String, default: 'root'
property :config, Hash, default: {}
property :nsswitch_name, String, name_property: true


action :create do

  config_resource = new_resource
  Chef::Log.fatal config_resource.config
  with_run_context :root do
    edit_resource('file', config_resource.filename) do
      content(create_content(config_resource.config))
      mode(config_resource.mode)
      owner(config_resource.owner)
      group(config_resource.group)

      action :nothing
      delayed_action :create
    end
  end
end
