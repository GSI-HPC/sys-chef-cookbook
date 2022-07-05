#
# Cookbook Name:: sys
# Integration tests for resource nftables
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

require 'spec_helper'

expected_rules = [
  /^table inet filter {$/,
  /\s+type filter hook output priority.*/,
  /\s+type filter hook forward priority.*/,
  /\s+tcp dport 7788 accept.*/,
  /\s+ip saddr 192.168.99.99 reject.*/,
  /\s+ip saddr { 192.168.99.99, 192.168.100.100 } drop.*/,
  /\s+ip daddr 192.168.99.99 reject.*/,
  /\s+ip daddr { 192.168.99.99, 192.168.100.100 } drop.*/,
  /\s+iif "lo" accept comment "allow loopback"/,
  /\s+icmp type echo-request accept.*$/,
  /\s+tcp dport 22 accept.*$/,
  /\s+udp dport 60000-61000 accept.*$/,
  /\s+ct state established,related accept.*$/,
  /\s+icmpv6 type { echo-request, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept.*$/,
  /\s+tcp dport { 2200, 2222 } accept.*$/,
  /\s+tcp dport 1234 drop.*$/,
  /\s+tcp dport 1235 reject.*$/,
  /\s+tcp dport 1236 drop.*$/,
  /\s+ip6 saddr 2001:db8::ff00:42:8329 tcp dport 80 accept.*$/,
  /\s+tcp dport 1000-1100 accept.*$/,
  /\s+tcp dport { 1234, 5000-5100, 5678 } accept.*$/,
  /\s+tcp dport 5000-5100 accept.*$/,
  %r{\s+ip saddr 127.0.0.0/8 tcp dport 2433 accept.*$},
  /\s+ip protocol esp accept.*$/,
  /\s+ip protocol ah accept.*$/,
  /\s+ip6 nexthdr esp accept.*$/,
  /\s+ip6 nexthdr ah accept.*$/,
]

cmd = 'nft list ruleset'

if os[:release].to_i >= 11
  expected_rules << /\s+type filter hook input priority filter; policy drop;/
else
  expected_rules << /\s+type filter hook input priority 0; policy drop;/
  cmd = 'nft -nn list ruleset'
end

if os[:release].to_i >= 10

  describe command(cmd) do
    expected_rules.each do |r|
      its(:stdout) { should match(r) }
    end
  end

  describe package('nftables') do
    it { should be_installed }
  end

  describe service('nftables') do
    it { should be_enabled }
    it { should be_running }
  end

else
  describe package('nftables') do
    it { should_not be_installed }
  end

  describe service('nftables') do
    it { should_not be_enabled }
    it { should_not be_running }
  end
end
