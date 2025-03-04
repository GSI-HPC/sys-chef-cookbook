# Cookbook Name:: sys
# Integration tests for recipe sys::nfs
#
# Copyright 2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

context 'not on Buster', if: debian_version != 10 do
  describe file '/var/log/syslog' do
    its(:content) { should match(/rpc.gssd\[\d+\]: libtirpc: debug level 7/) }
  end
end
