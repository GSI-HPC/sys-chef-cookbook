#
# Cookbook Name:: sys
# Unit test for LWRP sys_wallet
#
# Copyright 2015-2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn  <C.Huhn@gsi.de>
#  Matthias Pausch   <m.pausch@gsi.de>
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

describe 'lwrp: sys_wallet' do
  let(:runner) do
    ChefSpec::SoloRunner.new(
      :step_into => ['sys_wallet']
    ) do |n|
      n.default['sys']['krb5']['realm'] = 'example.com'
    end
  end

  describe 'action :deploy' do
    let(:chef_run) { runner.converge('fixtures::sys_wallet_deploy') }
    before do
      allow(File).to receive(:stat).and_call_original
      allow(File).to receive(:stat).with("/etc/krb5.keytab")
                       .and_return(::File.stat("/tmp"))

      # stub checks in check_krb5:
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("/etc/krb5.keytab").and_return(true)
      allow(File).to receive(:exist?).with("/usr/bin/kinit").and_return(true)
    end

    it 'deploys keytabs' do
      expect(chef_run).to run_bash('deploy host/node.example.com')
    end

    it 'changes permissions' do
      expect(chef_run).to create_file('/etc/krb5.keytab')
    end
  end
end
