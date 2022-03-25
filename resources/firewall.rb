#
# Cookbook Name:: sys
# Resource:: firewall
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

if Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

  action_class do

    include Sys::Helpers::Firewall

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

  #unified_mode true

  provides :firewall, os: 'linux', platform: %w(debian)

  property :rules, Hash

  def whyrun_supported?
    false
  end

  action :install do
    return unless managed?

    # Ensure the package is installed
    nft_pkg = package 'nftables' do
      action :nothing
    end
    nft_pkg.run_action(:install)

    with_run_context :root do
      edit_resource('sys_firewall', new_resource.name) do
        action :nothing
        delayed_action :rebuild
      end
    end
  end

  action :rebuild do
    return if !managed?

    ensure_default_rules_exist(node, new_resource)
    # prints all the firewall rules
    log_nftables

    # this takes the commands in each hash entry and builds a rule file
    nftables_file = lookup_or_create_rulesfile('/etc/nftables.conf')
    nftables_file.content "#!/usr/sbin/nft -f\nflush ruleset\n#{build_rule_file(new_resource.rules)}"
    nftables_file.run_action(:create)
    if disabled?
      new_resource.run_action(:disable)
      return
    end

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
    return unless managed?
    nftables_service = lookup_or_create_service('nftables')
    %i(disable stop).each do |a|
      nftables_service.run_action(a)
    end
  end
end
