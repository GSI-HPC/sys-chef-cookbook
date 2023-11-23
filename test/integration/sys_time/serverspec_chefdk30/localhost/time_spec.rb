# Cookbook Name:: sys
# Integration tests for recipe sys::time
#
# Copyright 2020-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
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

context 'timezone' do

  let(:tz) { %w[Antarctica Troll] }

  describe package('tzdata') do
    it { should be_installed }
  end

  describe file('/etc/timezone') do
    # its(:content) { should match(tz.join('/')) }
    it { should be_readable.by('others') }
  end

  describe command('debconf-show  tzdata ') do
    # its(:stdout) { should match(%r{^\* tzdata/Areas: #{tz[0]}$}) }
    its(:stdout) do
      should match(%r{^\* tzdata/Zones/#{tz[0]}: #{tz[1]}$})
    end
  end

  describe file('/etc/localtime') do
    it { should be_readable.by('others') }
    # it { should be_linked_to("/usr/share/zoneinfo/#{tz.join('/')}") }
  end
end



context 'ntp' do

  ntp_servers = %w[ntp1.net.berkeley.edu time1.esa.int zeit.fu-berlin.de]
  ntp_conf = if os[:platform] == 'debian' && os[:release].to_i >= 12
               '/etc/ntpsec/ntp.conf'
             else
               '/etc/ntp.conf'
             end

  describe file(ntp_conf) do
    its(:mode) { should eq "644" }
    ntp_servers.each do |srv|
      its(:content) { should match("server #{srv}") }
    end
  end

  describe service('ntp') do
    xit { should be_enabled }
    it { should be_running }
  end

  describe command('ntpq -p') do
    its(:exit_status) { should be_zero }
    ntp_servers.each do |srv|
      its(:stdout) { should match(/^[+* ]#{srv[0..14]} +/) }
    end
  end

end
