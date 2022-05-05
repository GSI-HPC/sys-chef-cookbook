#
# Cookbook:: sys
# Resource:: nftables
#
# Copyright:: 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

if Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

  action_class do
    include Sys::Helpers::Nftables

    def lookup_or_create_service(name)
      begin
        nftables_service = Chef.run_context.resource_collection.find(service: name)
      rescue
        nftables_service = service name do
          action :nothing
        end
      end
      nftables_service
    end

    def lookup_or_create_rulesfile(name)
      begin
        nftables_file = Chef.run_context.resource_collection.find(file: name)
      rescue
        nftables_file = file name do
          action :nothing
        end
      end
      nftables_file
    end
  end

  provides :nftables, os: 'linux', platform: %w(debian)
  # unified_mode true

  property :rules,
           Hash
  property :input_policy,
           String,
           equal_to: %w(drop accept),
           default: 'accept'
  property :output_policy,
           String,
           equal_to: %w(drop accept),
           default: 'accept'
  property :forward_policy,
           String,
           equal_to: %w(drop accept),
           default: 'accept'
  property :table_ip_nat,
           [true, false],
           default: false
  property :table_ip6_nat,
           [true, false],
           default: false

  def whyrun_supported?
    false
  end

  action :install do
    # Ensure the package is installed
    nft_pkg = package 'nftables' do
      action :nothing
    end
    nft_pkg.run_action(:install)

    with_run_context :root do
      edit_resource('sys_nftables', new_resource.name) do
        action :nothing
        delayed_action :rebuild
        forward_policy new_resource.forward_policy
        output_policy new_resource.output_policy
        input_policy new_resource.input_policy
        table_ip_nat new_resource.table_ip_nat
        table_ip6_nat new_resource.table_ip6_nat
      end
    end
  end

  action :rebuild do
    ensure_default_rules_exist(new_resource)

    # this takes the commands in each hash entry and builds a rule file
    nftables_file = lookup_or_create_rulesfile('/etc/nftables.conf')
    nftables_file.content "#!/usr/sbin/nft -f\nflush ruleset\n#{build_rule_file(new_resource.rules)}"
    nftables_file.run_action(:create)

    return if new_resource.action.include?(:disable)

    nftables_service = lookup_or_create_service('nftables')
    nftables_service.run_action(:enable)

    if nftables_file.updated_by_last_action?
      nftables_service.run_action(:restart)
    else
      nftables_service.run_action(:start)
    end
  end

  action :restart do
    nftables_service = lookup_or_create_service('nftables')
    nftables_service.run_action(:restart)
  end

  action :disable do
    nftables_service = lookup_or_create_service('nftables')
    %i(disable stop).each do |a|
      nftables_service.run_action(a)
    end
  end
end
