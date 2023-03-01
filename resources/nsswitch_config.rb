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

if Gem::Requirement.new('>= 12.15')
     .satisfied_by?(Gem::Version.new(Chef::VERSION))

  action_class do
    def sort_sources(config)
      sorted_sources = {}
      config.each do |db, sources_hash|
        sources_by_prio = sources_hash.group_by {|_src, prio| prio}
        sorted_prios = sources_by_prio.keys.sort
        sorted_prios.each do |prio|
          sorted_sources[db] ||= []
          sorted_sources[db] << sources_by_prio[prio].map { |s| s.first }.sort
        end
        sorted_sources[db].flatten!
      end
      sorted_sources
    end
  end

  property :filename, String, default: '/etc/nsswitch.conf'
  property :mode, String, default: '0644'
  property :owner, String, default: 'root'
  property :group, String, default: 'root'
  property :config, Hash, default: {}
  property :nsswitch_name, String, name_property: true

  default_action :create

  action :create do
    template new_resource.filename do
      source 'etc_nsswitch.conf.erb'
      variables(
        config: sort_sources(new_resource.config)
      )
      mode new_resource.mode
      owner new_resource.owner
      group new_resource.group
    end
  end
end
