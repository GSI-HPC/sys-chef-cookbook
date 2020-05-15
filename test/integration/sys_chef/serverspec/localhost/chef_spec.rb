#
# Cookbook Name:: sys
# Serverspec integration tests for sys::chef
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

context 'chef-client config' do
  before(:all) do
    # start chef-zero
    `/opt/chef/embedded/bin/chef-zero --daemon --port 4000`
  end

  describe command('chef-client') do
    its(:exit_status) { should be_zero }
    its(:stdout) { should contain('Chef Run complete') }
  end
end
