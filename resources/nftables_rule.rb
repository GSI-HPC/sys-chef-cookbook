#
# Cookbook:: sys
# Resource:: nftables_rule
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
  require 'ipaddr'
  action_class do
    include Sys::Helpers::Nftables

    def return_early?(new_resource)
      !new_resource.notify_nftables ||
        !(new_resource.action.include?(:create) &&
          !new_resource.should_skip?(:create))
    end
  end

  provides :nftables_rule
  # unified_mode true
  default_action :create

  property :nftables_name,
           String,
           default: 'default'
  property :command,
           Symbol,
           default: :allow,
           equal_to: %i(
           accept allow deny drop log masquerade redirect reject
           )
  property :protocol,
           [Integer, Symbol],
           default: :tcp,
           callbacks: { 'must be valid IP protocol specification' =>
                        lambda do |p|
                          %i(udp tcp icmp icmpv6 ipv6-icmp esp ah ipv6 none).include?(p) || (0..142).include?(p)
                        end }
  property :direction,
           Symbol,
           equal_to: [:in, :out, :pre, :post, :forward],
           default: :in
  property :logging,
           Symbol,
           equal_to: [:connections, :packets]
  # nftables handles ip6 and ip simultaneously.  Except for directions
  # :pre and :post, where where either :ip6 or :ip must be specified.
  # callback should prevent from mixing that up.
  property :family,
           Symbol,
           equal_to: [:ip6, :ip],
           default: :ip
  property :source,
           [String, Array]
  property :sport,
           [Integer, String, Array, Range]
  property :interface,
           String
  property :dport,
           [Integer, String, Array, Range]
  property :destination,
           [String, Array],
           callbacks: {
             'must be a valid ip address' => lambda do |ips|
               Array(ips).inject(false) do |a, ip|
                 a || !!IPAddr.new(ip)
               end
             end,
           }
  property :outerface,
           String
  property :position,
           Integer,
           default: 50
  property :stateful,
           [Symbol, Array]
  property :redirect_port,
           Integer
  property :description,
           String,
           name_property: true
  property :include_comment,
           [true, false],
           default: true
  # for when you just want to pass a raw rule
  property :raw,
           String
  # do you want this rule to notify the nftables to recalculate
  # (and potentially reapply) the nftables_rule(s) it finds?
  property :notify_nftables,
           [true, false],
           default: true

  action :create do
    return if return_early?(new_resource)
    fwr = build_nftables_rule(new_resource)

    with_run_context :root do
      begin
        edit_resource!('nftables', new_resource.nftables_name) do |fw_rule|
          r = rules.dup || {}
          r.merge!({
            fwr => fw_rule.position,
          })
          rules(r)
          delayed_action :rebuild
        end
      rescue Chef::Exceptions::ResourceNotFound
        Chef::Log.warn "Resource nftables['#{new_resource.nftables_name}'] not found in resource collection.  Not configuring nftables."
      end
    end
  end
end
