# Cookbook Name:: sys
# Integration tests for recipe sys::nsswitch
#
# Copyright 2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

describe file('/etc/nsswitch.conf') do
  it { should exist }
  it { should be_file } # link has been replaced

  # standard settings
  its(:content) { should match(/passwd:\s+compat/) }
  its(:content) { should match(/group:\s+compat/) }
  its(:content) { should match(/shadow:\s+compat/) }
  its(:content) { should match(/gshadow:\s+files/) }
  its(:content) { should match(/hosts:\s+files dns/) }
  its(:content) { should match(/networks:\s+files/) }
  its(:content) { should match(/protocols:\s+db files/) }
  its(:content) { should match(/services:\s+db files/) }
  its(:content) { should match(/ethers:\s+db files/) }
  its(:content) { should match(/rpc:\s+db files/) }
  its(:content) { should_not match(/sources:\s+nis/) }
end
