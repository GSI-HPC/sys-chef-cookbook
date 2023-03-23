#
# Cookbook Name:: sys
# Integration tests for sys::banner
#
# Copyright 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

describe file('/etc/motd') do
  its(:content) { should match 'Space: the final frontier.' }
end

describe file('/etc/profile.d/info.sh') do
  it { should exist }
end

describe command('sh -n /etc/profile.d/info.sh') do
  its(:exit_status) { should be_zero }
end

describe command('env PS1=bla /etc/profile.d/info.sh') do
  its(:exit_status) { should be_zero }
  its(:stdout) do
    should contain %r{^RAM:\s+\d+\.\d+MB total -- \d+\.\d+MB \(\d+%\) free \[\d+% with cache\]}
  end
end
