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
    package 'nftables' do
      action :install
      notifies :rebuild, "nftables[#{new_resource.name}]"
    end
  end

  action :rebuild do
    ensure_default_rules_exist(new_resource)

    file '/etc/nftables.conf' do
      content "#!/usr/sbin/nft -f\nflush ruleset\n#{build_rule_file(new_resource.rules)}"
      mode '0750'
      owner 'root'
      group 'root'
      notifies :restart, 'service[nftables]'
    end

    return if new_resource.action.include?(:disable)
    service 'nftables' do
      action [:enable, :start]
    end
  end

  action :restart do
    service 'nftables' do
      action :restart
    end
  end

  action :disable do
    service 'nftables' do
      action [:disable, :stop]
    end
  end
end
