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
]

if os[:release].to_i >= 10

  describe command('nft -nn list ruleset') do
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
end
