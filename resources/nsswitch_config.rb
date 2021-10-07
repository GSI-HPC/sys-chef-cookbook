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
  def sources_to_hash(sources)
    return sources if sources.instance_of?(Hash)

    sources_as_hash = {}
    sources.each_with_index do |s, i|
      sources_as_hash[s] = 10*(i + 1)
    end
    return sources_as_hash
  end

  def lookup_or_create_nsswitch_conf(name)
    begin
      nsswitch_conf = Chef.run_context.resource_collection.find(file: name)
    rescue
      nsswitch_conf = file name do
        action :nothing
      end
    end
    nsswitch_conf
  end
end

property :filename, String, name_property: true
property :mode, String, default: '0644'
property :owner, String, default: 'root'
property :group, String, default: 'root'

action :create do
  Chef::Log.fatal(Chef.run_context.resource_collection.map {|r| r.ancestors })
  nsswitches = Chef.run_context.resource_collection.select do |item|
    item.is_a?(Chef::Resource::Nsswitch)
  end
  nsswitches.each do |nsswitch|
    nsswitch.sources = sources_to_hash(new_resource.sources)
  end

  # nsswitches_by_databse = {
  #   'automount' => [automount_resource, automount_with_sssd_resource]
  #   'passwd' => [passwd_resource]
  # }
  nsswitches_by_database = nsswitches.group_by { |nsswitch| nsswitch.database }
  new_config = ''
  nsswitches_by_database.each do |db, nss_resources|
    config ||= {}
    nss_resources.each do |r|
      config[db].merge!(r.sources) do |_key, old, new|
        if new_resource.merge
          [old, new].flatten.sort.uniq
        else
          new
        end
      end
    end
    new_config << "#{db}: "
    sorted_sources = merged_sources.keys.sort.inject([]) do |a, key|
      a << merged_sources[key]
    end
    new_config << sorted_sources.join(' ')
  end

  nsswitch_file = lookup_or_creaet_nsswitch_conf(new_resource.filename)
  nsswitch_file.content = new_config
  nsswitch_file.run_action(:create)

  return unless nsswitch_file.updated_by_last_action?

  new_resource.updated_by_last_action(true)
end
