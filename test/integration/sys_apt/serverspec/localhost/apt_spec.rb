#
# Cookbook Name:: sys
# Serverspec integration tests for sys::apt
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

describe command('dpkg --configure -a') do
  its(:exit_status) { should be_zero }
  its(:stdout) { should be_empty }
  its(:stderr) { should be_empty }
end

describe command('apt-get -qq update') do
  its(:exit_status) { should be_zero }
  its(:stdout) { should be_empty }
  its(:stderr) { should be_empty }
end

describe file('/etc/apt/apt.conf.d/51languages') do
  it { should exist }
  its(:content) do
    should include('Acquire::Languages "none";')
  end
end

describe file('/etc/apt/preferences.d/sid') do
  it { should exist }
  its(:content) { should include('Package: *') }
  its(:content) { should include('Pin: release l=Debian,n=sid') }
  its(:content) { should include('Pin-Priority: 333') }
end
