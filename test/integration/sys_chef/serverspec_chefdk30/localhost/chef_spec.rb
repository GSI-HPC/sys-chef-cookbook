#
# Cookbook Name:: sys
# Serverspec integration tests for sys::chef
#
# Copyright 2020-2023 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

begin
  require 'chef_zero/server'
rescue LoadError
  STDERR.puts 'Cannot load chef_zero/server - TESTS HAVE BEEN SKIPPED'
  return
end

context 'chef-client config' do
  before(:all) do
    # start chef-zero
    server = ChefZero::Server.new(port: 4000)
    server.start_background

    # create dummy key:
    `openssl genrsa -out /etc/chef/client.pem`
  end

  describe command('chef-client') do
    its(:exit_status) { should be_zero }
    its(:stdout) { should contain %r{(Chef Run|Infra Phase) complete} }
  end
end

context 'not on Stretch', if: os[:release].to_i >= 10 || os[:family] != 'debian' do
  # this check fails on Stretch:
  describe service 'chef-client.timer' do
    it { should be_running }
    it { should be_enabled }
  end
end

describe service 'chef-client-oneshot.service' do
  it { should_not be_running } # oneshot servive
  it { should_not be_enabled } # triggered by timer
end

describe command 'systemctl status chef-client-oneshot.service' do
  # chef should not be running in daemon mode:
  its(:stdout) { should_not match %r{/usr/bin/chef-client\s(.*\s)?-d\s} }
end
