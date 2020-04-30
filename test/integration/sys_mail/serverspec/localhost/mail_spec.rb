#
# Cookbook Name:: sys
# Serverspec integration tests for sys::mail
#
# Copyright 2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

describe package 'postfix' do
  it { should be_installed }
end

describe service('postfix') do
  # this check does not work on Travis for Debian Stretch
  xit { should be_enabled }
  it { should be_running }
end

describe file('/etc/mailname') do
  it { should exist }
  its(:content) do
    should include(host_inventory['fqdn'])
  end
end

describe file('/etc/postfix/main.cf') do
  it { should exist }
end

maps = %w[/etc/aliases /etc/postfix/canonical /etc/postfix/virtual]

maps.each do |mapfile|
  describe file(mapfile) do
    it { should exist }
  end

  describe file("#{mapfile}.db") do
    it { should exist }
  end

  describe command("/usr/bin/test \"#{mapfile}\" -ot \"#{mapfile}.db\"") do
    its(:exit_status) { should be_zero }
  end
end

# real-life test:
#  mail to array will be written to /tmp/mail.test
#  as configured in /etc/alieases
describe file('/tmp/mail.test') do
  before(:all) do
    @timestamp = Time.now.strftime("%Y_%m_%d_%H_%M_%S")

    `echo "test mail #{@timestamp}" | mail -s "test-kitchen mail test" array`
    # wait for creation of mailbox:
    (1..10).each do |i|
      File.exist?('/tmp/mail.test') && break
      puts i
      sleep 1
    end
  end

  it { should exist }
  its(:content) { should include('Subject: test-kitchen mail test') }
  its(:content) { should include("test mail #{@timestamp}") }

  # 'To: <mail@bla>' on Debian, 'To: mail@bla' on CentOS
  its(:content) { should match(/^To: <?array@/) }
end
