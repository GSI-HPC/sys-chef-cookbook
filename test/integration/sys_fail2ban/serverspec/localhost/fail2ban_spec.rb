#
# Cookbook Name:: sys
# Serverspec integration tests for sys::fail2ban
#
# Copyright 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

describe package 'fail2ban' do
  it { should be_installed }
end

describe service 'fail2ban' do
  it { should be_enabled }
  it { should be_running }
end

describe file '/etc/fail2ban/jail.local' do
  its(:content) { should include('bantime') }
end

describe command 'fail2ban-client status' do
  its(:stdout) { should match(/Number of jail:\s+\d+/) }
  its(:stdout) { should match(/Jail list:\s+sshd/) }
end

describe command 'fail2ban-client get sshd bantime' do
  its(:stdout) { should eq "#{123*60}\n" }
end

describe file '/var/log/syslog' do
  if os[:release].to_i <= 9
    its(:content) { should match(/Started Fail2Ban Service/) }
  else
    its(:content) { should match(/fail2ban-server\[\d+\]: Server ready$/) }
  end
end
