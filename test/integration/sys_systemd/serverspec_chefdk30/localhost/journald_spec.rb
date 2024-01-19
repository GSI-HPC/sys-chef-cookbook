# Cookbook Name:: sys
# Integration tests for recipe sys::systemd systemd unit config
#
# Copyright 2022-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

describe file '/etc/systemd/journald.conf' do
  it { should exist }
  its(:content) { should match %r{^# This file is managed by (chef|cinc)} }
  its(:content) { should match %r{^Storage=volatile$} }
end

describe service 'systemd-journald' do
  it { should be_running }
end
