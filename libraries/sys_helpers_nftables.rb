#
# Cookbook:: sys
# Library:: Helpers::Nftables
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

module Sys
  module Helpers
    module Nftables
      require 'ipaddr'
      include Chef::Mixin::ShellOut

      def valid_ips?(ips)
        Array(ips).inject(false) do |a, ip|
          a || !!IPAddr.new(ip)
        end
      end

      # ips could be like '192.0.2.1', but also '$some_variable'
      def s2ip_with_prefix(ip)
        # Only works on buster and newer. In older debian-versions
        # there is no prefix-method for IPv4-addresses.
        addr = IPAddr.new(ip)
        "#{addr}/#{addr.prefix}"
      rescue IPAddr::InvalidAddressError
        ip
      end

      def build_set_of_ips(ips)
        if ips.instance_of?(String)
          s2ip_with_prefix(ips)
        else
          ips.map! do |ip|
            s2ip_with_prefix(ip)
          end
          if ips.length == 1
            ips.first
          else
          "{#{ips.join(', ')}}"
          end
        end
      end

      def port_to_s(port)
        if port.is_a?(String)
          port
        elsif port && port.is_a?(Integer)
          port.to_s
        elsif port && port.is_a?(Array)
          port_strings = port.map { |o| port_to_s(o) }
          "{#{port_strings.sort.join(',')}}"
        elsif port && port.is_a?(Range)
          "#{port.first}-#{port.last}"
        end
      end

      def build_rule_file(rules)
        contents = []
        sorted_values = rules.values.sort.uniq
        sorted_values.each do |sorted_value|
          contents << "# position #{sorted_value}"
          contents << rules.select { |_, v| v == sorted_value }.keys.join("\n")
        end
        "#{contents.join("\n")}\n"
      end

      CHAIN ||= {
        in: 'input',
        out: 'output',
        pre: 'prerouting',
        post: 'postrouting',
        forward: 'forward',
      }.freeze

      TARGET ||= {
        accept: 'accept',
        allow: 'accept',
        counter: 'counter',
        deny: 'drop',
        drop: 'drop',
        log: 'log',
        masquerade: 'masquerade',
        redirect: 'redirect',
        reject: 'reject',
      }.freeze

      def nftables_command_log(rule_resource)
        log_prefix = 'prefix '
        log_prefix << if rule_resource.log_prefix.nil?
                        "\"#{CHAIN[rule_resource.direction]}:\""
                      else
                        "\"#{rule_resource.log_prefix}\""
                      end
        log_group = if rule_resource.log_group.nil?
                      nil
                    else
                      "group #{rule_resource.log_group} "
                    end
        "log #{log_prefix} #{log_group}"
      end

      def nftables_command_redirect(rule_resource)
        if rule_resource.redirect_port.nil?
          raise 'Specify redirect_port when using :redirect as commmand'
        end

        "redirect to #{rule_resource.redirect_port} "
      end

      def nftables_commands(rule_resource)
        nftables_rule = ''
        commands = Array(rule_resource.command).map do |command|
          begin
            TARGET.fetch(command.to_sym)
          rescue KeyError
            raise "Invalid command: #{command.inspect}. Use one of #{TARGET.keys}"
          end
        end

        commands.sort!.uniq!
        # Add non-terminal statements first
        if commands.include?('log')
          nftables_rule << nftables_command_log(rule_resource)
          commands -= ['log']
        end
        if commands.include?('counter')
          nftables_rule << 'counter '
          commands -= ['counter']
        end
        raise "Only one terminal statement is possible, provided were #{commands.join(',')}" if commands.length > 1
        commands.each do |cmd|
          nftables_rule << case cmd
                           when 'redirect'
                             nftables_command_redirect(rule_resource)
                           else
                             "#{cmd} "
                           end
        end
        nftables_rule
      end

      def build_nftables_rule(rule_resource)
        return rule_resource.raw.strip if rule_resource.raw

        ip_family = rule_resource.family
        table = if [:pre, :post].include?(rule_resource.direction)
                  'nat'
                else
                  'filter'
                end
        nftables_rule = if table == 'nat'
                          "add rule #{ip_family} #{table} "
                        else
                          "add rule inet #{table} "
                        end
        nftables_rule << CHAIN.fetch(rule_resource.direction.to_sym)
        nftables_rule << ' '
        nftables_rule << "iif #{rule_resource.interface} " if rule_resource.interface
        nftables_rule << "iifname #{rule_resource.interface_name} " if rule_resource.interface_name
        nftables_rule << "oif #{rule_resource.outerface} " if rule_resource.outerface
        nftables_rule << "oifname #{rule_resource.outerface_name} " if rule_resource.outerface_name

        if rule_resource.source
          source_set = build_set_of_ips(rule_resource.source)
          nftables_rule << "#{ip_family} saddr #{source_set} "
        end

        if rule_resource.destination
          destination_set = build_set_of_ips(rule_resource.destination)
          nftables_rule << "#{ip_family} daddr #{destination_set} "
        end

        case rule_resource.protocol
        when :icmp
          nftables_rule << 'icmp type echo-request '
        when :'ipv6-icmp', :icmpv6
          nftables_rule << 'icmpv6 type { echo-request, nd-router-solicit, nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } '
        when :tcp, :udp
          nftables_rule << "#{rule_resource.protocol} sport #{port_to_s(rule_resource.sport)} " if rule_resource.sport
          nftables_rule << "#{rule_resource.protocol} dport #{port_to_s(rule_resource.dport)} " if rule_resource.dport
        when :esp, :ah
          nftables_rule << "#{ip_family} #{ip_family == :ip6 ? 'nexthdr' : 'protocol'} #{rule_resource.protocol} "
        when :none
          nil # do nothing
        else
          nftables_rule << "#{ip_family} protocol #{rule_resource.protocol} "
        end

        nftables_rule << "ct state #{Array(rule_resource.stateful).join(',').downcase} " if rule_resource.stateful
        nftables_rule << nftables_commands(rule_resource)
        nftables_rule << "comment \"#{rule_resource.description}\" " if rule_resource.include_comment
        nftables_rule.strip!
        nftables_rule
      end

      def default_ruleset(new_resource)
        rules = {
          'add table inet filter' => 1,
          "add chain inet filter input { type filter hook input priority 0 ; policy #{new_resource.input_policy}; }" => 2,
          "add chain inet filter output { type filter hook output priority 0 ; policy #{new_resource.output_policy}; }" => 2,
          "add chain inet filter forward { type filter hook forward priority 0 ; policy #{new_resource.forward_policy}; }" => 2,
        }
        if new_resource.table_ip_nat
          rules['add table ip nat'] = 1
          rules['add chain ip nat postrouting { type nat hook postrouting priority 100 ;}'] = 2
          rules['add chain ip nat prerouting { type nat hook prerouting priority -100 ;}'] = 2
        end
        if new_resource.table_ip6_nat
          rules['add table ip6 nat'] = 1
          rules['add chain ip6 nat postrouting { type nat hook postrouting priority 100 ;}'] = 2
          rules['add chain ip6 nat prerouting { type nat hook prerouting priority -100 ;}'] = 2
        end
        rules
      end

      def ensure_default_rules_exist(new_resource)
        input = new_resource.rules || {}
        new_resource.rules = input.merge!(default_ruleset(new_resource))
      end
    end
  end
end
