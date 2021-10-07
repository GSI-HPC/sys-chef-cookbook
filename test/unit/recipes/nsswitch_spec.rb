#
# Cookbook Name:: sys
# Unit tests for nsswitch recipe
#
# Copyright 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn <C.Huhn@gsi.de>
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

describe 'sys::nsswitch' do

  context "node['sys']['nsswitch'] is empty" do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['nsswitch']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'adds defaults to nsswitch.conf' do
      expect(chef_run).to render_file('/etc/nsswitch.conf')
                            .with_content(/^passwd: +compat/)
                            .with_content(/^hosts: files dns/)
    end

  end
end
