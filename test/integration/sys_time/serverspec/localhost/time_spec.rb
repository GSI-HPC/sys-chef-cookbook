# Cookbook:: sys
# Integration tests for recipe sys::time
#
# Copyright:: 2020-2025 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

  before :all do
    # prepare kitchen VM to resolve ntp-observer.example.org to
    #  its own  public IP:
    File.open('/etc/hosts', 'a') do |hosts|
      hosts.puts host_inventory['ohai']['ipaddress'] +
                 " ntp-observer.example.org"
    end
  end

  # we hat to restart ntpd so it is able to resolve ntp-observer.example.org:
  describe command 'systemctl restart ntp' do
    its(:exit_status) { should be_zero }
    its(:stdout) { should be_empty }
    its(:stderr) { should be_empty }
  end

  ntp_servers = %w[ntp1.net.berkeley.edu time1.esa.int zeit.fu-berlin.de]
  ntp_conf = debian_version >= 12 ? '/etc/ntpsec/ntp.conf' : '/etc/ntp.conf'

  describe file(ntp_conf) do
    its(:mode) { should eq "644" }
    ntp_servers.each do |srv|
      its(:content) { should match(/^server #{srv} iburst/) }
    end
    its(:content) do
      # ACL for ntp-observer.example.org must not contain noquery:
      should match(/^restrict ntp-observer.example.org default (?!.*noquery)/)
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

  describe command('ntpq -c rv ntp-observer.example.org') do
    before :all do
      # prepare kitchen VM to resolve ntp-observer.example.org to
      #  its own  public IP:
      File.open('/etc/hosts', 'a') do |hosts|
        hosts.puts host_inventory['ohai']['ipaddress'] +
                   " ntp-observer.example.org"
      end
    end

    its(:exit_status) { should be_zero }
    %w[stratum sys_jitter peer expire version].each do |key|
      its(:stdout) { should match(/(^|, )#{key}=.*(,|$)/) }
    end
  end

end
