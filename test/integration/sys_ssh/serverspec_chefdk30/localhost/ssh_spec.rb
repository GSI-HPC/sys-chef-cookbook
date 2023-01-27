# Cookbook Name:: sys
# Integration tests for recipe sys::ssh
#
# Copyright 2020-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

#
# SSH is difficult to test as it is already configured and running inside vagrant VMs
#
require 'spec_helper'

### node['sys']['sshd']['config']:

describe package('openssh-server') do
  it { should be_installed }
end

describe service('ssh') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/ssh/sshd_config') do
  it { should exist }
  # picked up default:
  its(:content) { should match(/^UsePAM yes$/) }
  # overwritten default:
  its(:content) { should match(/^X11Forwarding no$/) }
  its(:content) { should_not match(/^X11Forwarding yes$/) }
  # custom setting:
  its(:content) { should match(/^ClientAliveInterval 4711/) }
end

### node['sys']['ssh']['ssh_config']:

describe file('/etc/ssh/ssh_config') do
  it { should exist }
  its(:content) { should match(/Host \*\.example\.org\n\s+SendEnv TGIF/m) }
end

### node['sys']['ssh']['authorize']

describe user('root') do
  it { should exist }
end

describe file('/root/.ssh') do
  it { should exist }
  it { should be_directory }
  it { should be_mode('700') }
end

# the homedir should not be writable and sys_ssh_authorize should catch that
#  without failing
describe file('/home/mchammer/.ssh/authorized_keys') do
  it { should_not exist }
end

describe file('/root/.ssh/authorized_keys') do
  it { should exist }
  its(:content) do
    should include 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZ7mI0iEdW2GmHZv+0OknkPDkQaBowEDzfaal2A+eRR'
  end
end

### node['sys']['ssh']['config']:

describe file('/root/.ssh/config') do
  it { should exist }
  it { should be_mode('600') }
  its(:content) do
    should match(/^Host \*\n\s*AddKeysToAgent ask$/m)
  end
end

# test /etc/ssh/ssh_known_hosts
describe file('/etc/ssh/ssh_known_hosts') do
  it { should exist }
  it { should be_mode('644') }
  its(:content) do
    should match(/^github.com ssh-rsa AAAA\S+==$/)
  end
end

describe command 'ssh -o BatchMode=yes -v git@git.gsi.de' do
  its(:exit_status) { should eq 255 } # permission denied
  its(:stdout) { should be_empty }
  its(:stderr) { should include "debug1: Host 'git.gsi.de' is known and matches the ECDSA host key." }
  its(:stderr) { should match %r{^debug1: Found key in /etc/ssh/ssh_known_hosts:\d+} }
end
