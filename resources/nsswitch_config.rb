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
  property :use_defaults, [true, false], default: true

  default_action :create

  action :create do
    default_config = {}
    if new_resource.use_defaults
      default_config = {
        passwd:    { 'files' => 10 },
        group:     { 'files' => 10 },
        shadow:    { 'files' => 10 },
        gshadow:   { 'files' => 10 },
        hosts:     { 'files' => 10, 'dns' => 20 },
        networks:  { 'files' => 10 },
        protocols: { 'files' => 10 },
        services:  { 'files' => 10 },
        ethers:    { 'files' => 10 },
        rpc:       { 'files' => 10 },
      }.map { |k,v| [k.to_s, v] }.to_h
    end

    default_config.merge!(new_resource.config) do |_k,default_v,config_v|
      default_v.merge(config_v)
    end

    template new_resource.filename do
      source 'etc_nsswitch.conf.erb'
      cookbook 'sys'
      variables(
        config: sort_sources(default_config)
      )
      mode new_resource.mode
      owner new_resource.owner
      group new_resource.group
    end
  end
end
