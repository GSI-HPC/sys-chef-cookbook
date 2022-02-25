#
# Author:: Matthias Pausch (<m.pausch@gsi.de>)
# Cookbook Name:: sys
# Resource:: firewall_rule
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
  require 'ipaddr'
  action_class do
    include Sys::Helpers::Firewall

    def return_early?(new_resource)
      !new_resource.notify_firewall ||
        !(new_resource.action.include?(:create) &&
          !new_resource.should_skip?(:create)) ||
        !managed?
    end
  end

  provides :firewall_rule
  default_action :create

  property :firewall_name, String, default: 'default'

  property :command, Symbol, default: :allow, equal_to: %i[
    accept allow deny drop log masquerade redirect reject
  ]

  property :protocol, [Integer, Symbol], default: :tcp,
    callbacks: { 'must be either :tcp, :udp, :icmp, :\'ipv6-icmp\', :icmpv6, :none, or a valid IP protocol number' =>
      ->(p) do
        %i[udp tcp icmp icmpv6 ipv6-icmp esp ah ipv6 none].include?(p) || (0..142).include?(p)
      end }
  property :direction, Symbol, equal_to: [:in, :out, :pre, :post, :forward], default: :in
  property :logging, Symbol, equal_to: [:connections, :packets]
  # nftables handles ip6 and ip simultaneously.  Except for directions
  # :pre and :post, where where either :ip6 or :ip must be specified.
  # callback should prevent from mixing that up.
  property :family, Symbol, equal_to: [:ip6, :ip], default: :ip
  property :source, [String, Array], callbacks: {
    'must be a valid ip address' => ->(ips) do
      Array(ips).inject(false) do |a, ip|
        a || !!IPAddr.new(ip)
      end
    end
  }
  property :source_port, [Integer, String, Array, Range] # source port
  property :interface, String

  # I would rather call them sport and dport, without alternatives.
  # However, firewall rules should be kept compatible with future
  # releases of the firewall cookbook from the sous-chefs.
  property :port, [Integer, String, Array, Range] # shorthand for dest_port
  property :destination, [String, Array], callbacks: {
    'must be a valid ip address' => ->(ips) do
      Array(ips).inject(false) do |a, ip|
        a || !!IPAddr.new(ip)
      end
    end
  }
  property :dest_port, [Integer, String, Array, Range]
  property :dest_interface, String

  property :position, Integer, default: 50
  property :stateful, [Symbol, Array]
  property :redirect_port, Integer
  property :description, String, name_property: true
  property :include_comment, [true, false], default: true

  # for when you just want to pass a raw rule
  property :raw, String

  # do you want this rule to notify the firewall to recalculate
  # (and potentially reapply) the firewall_rule(s) it finds?
  property :notify_firewall, [true, false], default: true

  action :create do
    return if return_early?(new_resource)

    with_run_context :root do
      edit_resource('sys_firewall', new_resource.firewall_name) do |fw_rule|
        r = rules.dup || {}
        r.merge!({
          build_firewall_rule(fw_rule) => fw_rule.position
        })
        rules(r)
        delayed_action :rebuild
      end
    end
  end
end
