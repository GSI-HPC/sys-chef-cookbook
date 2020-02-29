#
# Cookbook Name:: sys
# Unit tests for sys::modules
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

describe 'sys::modules' do

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context "node['sys']['modules'] is empty" do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context "with node['sys']['modules']" do

    let(:modules) do
      {
        my_mod:       [false,false],
        existing_mod: [true,false],
        loaded_mod:   [true, true]
      }
    end

    before do
      modules.each do |mod, bool|
        stub_command("grep \"^#{mod}$\" /etc/modules").and_return(bool.first)
        stub_command("lsmod | grep #{mod}").and_return(bool.last)
      end
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['modules'] = modules.keys.map(&:to_s)
      end.converge(described_recipe)
    end

    it 'enables modules' do
      modules.each do |mod, bool|
        if bool.first
          expect(chef_run).to_not run_execute("Enable module #{mod} in /etc/modules")
        else
          expect(chef_run).to run_execute("Enable module #{mod} in /etc/modules")
        end
      end
    end

    it 'loads modules' do
      modules.each do |mod, bool|
        if bool.last
          expect(chef_run).to_not run_execute("Load module #{mod}")
        else
          expect(chef_run).to run_execute("Load module #{mod}")
        end
      end
    end
  end

end
