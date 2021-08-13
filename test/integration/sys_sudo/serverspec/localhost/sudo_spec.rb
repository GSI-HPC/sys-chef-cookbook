#
# Cookbook Name:: sys
# Integration tests for sys::sudo
#
# Copyright 2019-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

describe file('/etc/sudoers') do
  it { should exist }
  its(:content) do
    should match(/Defaults\s+mailfrom="prosecutor@example.com"/)
    should match(/Defaults\s+mailto="daemon"/)
    should match(/Defaults\s+mailsub="\[SUDO\] RED ALERT!"/)
  end
end

describe file('/etc/sudoers.d/kitchen') do
  it { should exist }
  its(:content) { should match(/User_Alias SMUTJE = .*vagrant/) }
  its(:content) { should include('SMUTJE ALL=(ALL) NOPASSWD: ALL') }
end

# should have been cleaned up:
describe file('/etc/sudoers.d/vagrant') do
  it { should_not exist }
end

describe user('daemon') do
  it { should exist }
end

describe file('/etc/environment') do
  it { should exist }
  its(:content) { should match(/^FFF=.+/) }
end

# test for env_keep in /etc/sudoers.d/kitchen
describe command('sudo env') do
  its(:exit_status) { should be_zero }
  its(:stdout) { should match(/^FFF=.*/) }

  # fails on Bionic (different PAM config?):
  if os[:family] != 'ubuntu'
    its(:stdout) { should_not match(/^RESCUE=.*/)}
  end
end

# real-life test (fails on Bionic (different mail setup?))
describe file('/var/mail/daemon'), if: os[:family] != 'ubuntu' do
  # sudo something stupid as nobody:
  before do
    # silence sudo:
    FileUtils.touch('/var/lib/sudo/lectured/nobody')
    `yes | sudo -u nobody sudo --prompt='' --stdin whoami`
    # wait for creation of mailbox:
    (1..10).each do |i|
      File.exist?('/var/mail/daemon') && break
      puts i
      sleep 1
    end
  end

  it { should exist }
  its(:content) do
    should include 'From: prosecutor@example.com'
    should include '[SUDO] RED ALERT!'
    should match %r{nobody : user NOT in sudoers.*COMMAND=/usr/bin/whoami}
  end
end
