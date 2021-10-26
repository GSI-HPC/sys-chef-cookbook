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

#unified_mode true

provides :nsswitch

  property :database, String, name_property: true
  property :sources, [String, Array, Hash],
    coerce: proc { |sources|
      if sources.instance_of?(Hash)
        sources
      else
        sources_as_hash = {}
        Array(sources).each_with_index do |s, i|
          sources_as_hash[s] = 10*(i + 1)
        end
        sources_as_hash
      end
    }
  property :notify_nsswitch_config, [true, false], default: true

action_class do
  def sources_to_hash(sources)
    return sources if sources.instance_of?(Hash)

  action :create do
    return unless new_resource.notify_nsswitch_config
    nsswitch_resource = new_resource
    with_run_context :root do
      edit_resource('sys_nsswitch_config', 'default') do
        action :nothing
        old = config.dup
        old[nsswitch_resource.database] ||= {}
        old[nsswitch_resource.database].merge! nsswitch_resource.sources
        config(old)
      end
      log "Create nsswitch.conf!" do
        notifies :create, 'sys_nsswitch_config[default]', :delayed
      end
    end
  end
end
