#
# Cookbook Name:: sys
# Library:: Helpers::Firewall
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

module Sys
  module Helpers
    module Firewall
      require 'ipaddr'
      include Chef::Mixin::ShellOut

      def dport(new_resource)
        new_resource.dest_port || new_resource.port
      end

      def sport(new_resource)
        new_resource.source_port
      end

      def valid_ips?(ips)
        Array(ips).inject(false) do |a, ip|
          a || !!IPAddr.new(ip)
        end
      end

      def build_set_of_ips(ips)
        set_of_ips = Array(ips).map { |ip| IPAddr.new(ip) }

        # Only works on buster and newer. In older debian-versions
        # there is no prefix-method for IPv4-addresses.
        addrs = set_of_ips.map { |ip| "#{ip}/#{ip.prefix}" }
        if addrs.length == 1
          addrs.first
        else
          "{#{addrs.join(', ')}}"
        end
      end

      def port_to_s(p)
        if p.is_a?(String)
          p
        elsif p && p.is_a?(Integer)
          p.to_s
        elsif p && p.is_a?(Array)
          p_strings = p.map { |o| port_to_s(o) }
          "{#{p_strings.sort.join(',')}}"
        elsif p && p.is_a?(Range)
          "#{p.first}-#{p.last}"
        end
      end

      def build_rule_file(rules)
        contents = []
        sorted_values = rules.values.sort.uniq
        sorted_values.each do |sorted_value|
          contents << "# position #{sorted_value}"
          contents << rules.select { |_,v| v == sorted_value }.keys.join("\n")
        end
        "#{contents.join("\n")}\n"
      end

      unless defined? CHAIN
        CHAIN = {
          in: 'input',
          out: 'output',
          pre: 'prerouting',
          post: 'postrouting',
          forward: 'forward',
        }.freeze
      end

      unless defined? TARGET
        TARGET = {
          accept: 'accept',
          allow: 'accept',
          deny: 'drop',
          drop: 'drop',
          log: 'log prefix "nftables:" group 0',
          masquerade: 'masquerade',
          redirect: 'redirect',
          reject: 'reject',
        }.freeze
      end

      def build_firewall_rule(rule_resource)
        return rule_resource.raw.strip if rule_resource.raw

        ip_family = rule_resource.family
        table = if [:pre, :post].include?(rule_resource.direction)
                  'nat'
                else
                  'filter'
                end
        firewall_rule = if table == 'nat'
                          "add rule #{ip_family} #{table} "
                        else
                          "add rule inet #{table} "
                        end
        firewall_rule << CHAIN.fetch(rule_resource.direction.to_sym)
        firewall_rule << ' '
        firewall_rule << "iif #{rule_resource.interface} " if rule_resource.interface
        firewall_rule << "oif #{rule_resource.dest_interface} " if rule_resource.dest_interface

        if rule_resource.source
          source_set = build_set_of_ips(rule_resource.source)
          firewall_rule << "#{ip_family} saddr #{source_set} "
        end

        if rule_resource.destination
          destination_set = build_set_of_ips(rule_resource.destination)
          firewall_rule << "#{ip_family} daddr #{destination_set} "
        end

        case rule_resource.protocol
        when :icmp
          firewall_rule << 'icmp type echo-request '
        when :'ipv6-icmp', :icmpv6
          firewall_rule << 'icmpv6 type { echo-request, nd-router-solicit, nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } '
        when :tcp, :udp
          firewall_rule << "#{rule_resource.protocol} sport #{port_to_s(sport(rule_resource))} " if sport(rule_resource)
          firewall_rule << "#{rule_resource.protocol} dport #{port_to_s(dport(rule_resource))} " if dport(rule_resource)
        when :esp, :ah
          firewall_rule << "#{ip_family} #{ip_family == :ip6 ? 'nexthdr' : 'protocol'} #{rule_resource.protocol} "

        # nothing to do default :ipv6, :none
        end

        firewall_rule << "ct state #{Array(rule_resource.stateful).join(',').downcase} " if rule_resource.stateful
        firewall_rule << "#{TARGET[rule_resource.command.to_sym]} "
        firewall_rule << " to #{rule_resource.redirect_port} " if rule_resource.command == :redirect
        firewall_rule << "comment \"#{rule_resource.description}\" " if rule_resource.include_comment
        firewall_rule.strip!
        firewall_rule
      end

      def log_nftables
        shell_out!('nft -n list ruleset')
      rescue Mixlib::ShellOut::ShellCommandFailed
        Chef::Log.info('log_nftables failed!')
      rescue Mixlib::ShellOut::CommandTimeout
        Chef::Log.info('log_nftables timed out!')
      end

      def default_ruleset(new_resource)
        rules = {
          'add table inet filter' => 1,
          "add chain inet filter INPUT { type filter hook input priority 0 ; policy #{new_resource.input_policy}; }" => 2,
          "add chain inet filter OUTPUT { type filter hook output priority 0 ; policy #{new_resource.output_policy}; }" => 2,
          "add chain inet filter FOWARD { type filter hook forward priority 0 ; policy #{new_resource.forward_policy}; }" => 2,
        }
        if new_resource.table_ip_nat
          rules['add table ip nat'] = 1
          rules['add chain ip nat POSTROUTING { type nat hook postrouting priority 100 ;}'] = 2
          rules['add chain ip nat PREROUTING { type nat hook prerouting priority -100 ;}'] = 2
        end
        if new_resource.table_ip6_nat
          rules['add table ip6 nat'] = 1
          rules['add chain ip6 nat POSTROUTING { type nat hook postrouting priority 100 ;}'] = 2
          rules['add chain ip6 nat PREROUTING { type nat hook prerouting priority -100 ;}'] = 2
        end
        rules

      end

      def ensure_default_rules_exist(current_node, new_resource)
        input = new_resource.rules || {}
        input.merge!(default_ruleset(current_node).to_h)
        new_resource.rules(input)
      end
    end
  end
end
