# Cookbook Name:: sys
# Integration tests for recipe sys::linuxlogo
#
# Copyright 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

describe package 'linuxlogo' do
  it { should be_installed }
end

# process 'agetty' has multiple matches and serverspec only tests
#  the first match. Therfore we try harder to find the right process
describe command 'ps -t tty1 v' do
  its(:exit_status) { should be_zero }
  its(:stderr) { should be_empty }
  its(:stdout) do
    should match %r{agetty.* -f /etc/issue.linuxlogo }
  end
end
