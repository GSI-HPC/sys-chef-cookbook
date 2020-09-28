#
# Cookbook Name:: sys
# Unit test for recipe vm
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

describe 'sys::vm' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?)
                     .with('/dev/virtio-ports/org.qemu.guest_agent.0')
                     .and_return(true)
  end

  context 'node.sys.vm is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with vm attributes' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['vm']['install_guest_agent'] = true
      end.converge(described_recipe)
    end

    it 'installs qemu-guest-agent' do
      expect(chef_run).to install_package('qemu-guest-agent')
    end
  end
end
