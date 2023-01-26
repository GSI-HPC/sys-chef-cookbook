#
# Cookbook Name:: sys
# Serverspec integration tests for sys::fail2ban
#
# Copyright 2022-2023 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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
  its(:stdout) { should eq "1234\n" }
end

context 'test the banning' do

  before :all do
    # unsuccessfully connect to localhost via its public IP multiple times:
    cmd = "ssh -o StrictHostKeyChecking=no -o BatchMode=yes"\
          " -o ConnectTimeout=10"\
          " hackerman@#{host_inventory['ohai']['ipaddress']}"
    5.times do
      `#{cmd}`
      sleep 1
    end
  end

  describe file '/var/log/syslog' do
    if os[:release].to_i <= 9
      its(:content) { should match(/Started Fail2Ban Service/) }
    else
      its(:content) { should match(/fail2ban-server\[\d+\]: Server ready$/) }
    end

    # banning has been logged:
    its(:content) do
      should(
        match(
          %r{fail2ban.actions *\[\d+\]: NOTICE +\[sshd\] Ban #{host_inventory['ohai']['ipaddress']}$}
        )
      )
    end
  end

  describe command 'fail2ban-client status sshd' do
    its(:exit_status) { should be_zero }
    its(:stdout) do
      should match %r{`- Banned IP list:\s*#{host_inventory['ohai']['ipaddress']}}
    end
    its(:stderr) { should be_empty }
  end

end
