# Cookbook Name:: sys
# Integration tests for recipe sys::resolv
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

describe file('/etc/resolv.conf') do
  it { should exist }
  it { should be_file } # link has been replaced

  # standard settings
  its(:content) { should include "nameserver 8.8.8.8" }
  its(:content) { should include "nameserver 9.9.9.9" }
  its(:content) { should include "search gsi.de fair-center.eu" }

  # domain attribute overwritten and omitted:
  its(:content) { should_not match(/^\s*domain.*/) }

  # options
  its(:content) { should match(/^\s*options .+/) }
end

describe command('host www') do
  its(:exit_status) { should be_zero }
  its(:stdout) { should match(/^www\.gsi\.de has address 140\.181\.[0-9.]+$/) }
end
