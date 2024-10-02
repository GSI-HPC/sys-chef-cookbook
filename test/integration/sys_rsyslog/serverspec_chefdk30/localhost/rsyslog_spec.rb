#
# Cookbook Name:: sys
# Integration tests for recipe rsyslog
#
# Copyright 2023-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch   <m.pausch@gsi.de>
#  Christopher Huhn  <c.huhn@gsi.de>
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

describe service('rsyslog') do
  # serverspec's be_enabled is broken on Debian Testing:
  it { should be_enabled } if debian_version < 999
  it { should be_running }
end

describe file('/etc/rsyslog.d/20-loghost-test-tls.conf') do
  # brackets must be escaped in strings for test to work:
  its(:content) { should contain 'if prifilt\("authpriv.*"\) then {' }
  its(:content) { should contain 'target="192.168.144.120"' }
  its(:content) { should contain 'port="55514"' }
end

describe file('/etc/rsyslog.d/20-loghost-test-relp.conf') do
  it { should exist }
end

describe file('/etc/rsyslog.d/20-loghost-no-tls.conf') do
  it { should exist }
end

context 'Bullseye or later', if: debian_version >= 11 do
  describe package('rsyslog-openssl') do
    it { should be_installed }
  end

  describe file('/etc/rsyslog.d/20-loghost-test-tls.conf') do
    its(:content) { should contain 'StreamDriver="ossl"' }
  end

  describe file('/etc/rsyslog.d/loghost.conf') do
    it { should_not exist }
  end
end

context 'On Buster', if: debian_version.to_i== 10 do
  describe package('rsyslog-openssl') do
    it { should_not be_installed }
  end

  describe package('rsyslog-gnutls') do
    it { should be_installed }
  end

  describe file('/etc/rsyslog.d/20-loghost-test-tls.conf') do
    its(:content) { should match 'StreamDriver="gtls"' }
  end
end
