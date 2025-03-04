#
# Cookbook Name:: sys
# Integration tests for snmpd setup
#
# Copyright 2019-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
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

case os[:family]
when 'redhat'
  snmpd_package = 'net-snmp'
  snmpwalk_package = 'net-snmp-utils'
  snmp_user    = 'snmp'
when 'debian', 'ubuntu'
  snmpd_package = 'snmpd'
  snmpwalk_package = 'snmp'
  if debian_version >= 9
    snmp_user = 'Debian-snmp'
  else
    snmp_user = 'snmp'
  end
end

describe package(snmpd_package) do
  it { should be_installed }
end

describe service('snmpd') do
  it { should be_enabled }
  it { should be_running }
end

describe user(snmp_user) do
  it { should exist }
end

describe process('snmpd') do
  its(:user) { should eq snmp_user }
  its(:args) { should match %r{ -LS1d } }
end

describe package(snmpwalk_package) do
  it { should be_installed }
end

# query snmpd for sysContact.0:
describe command('snmpwalk -Ov -Oq -c oz -v2c localhost .1.3.6.1.2.1.1.4.0') do
  its(:stdout) { should match(/Dorothy Gale/) }
  its(:exit_status) { should eq 0 }
end
