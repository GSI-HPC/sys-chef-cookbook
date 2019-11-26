#
# Cookbook Name:: sys
# Unit tests for hosts recipe
#
# Copyright 2016-2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn    <c.huhn@gsi.de>
#  Gabriele Iannetti   <g.iannetti@gsi.de>
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

describe 'sys::hosts' do

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'check if all resources are present' do
    chef_run.run_context.resource_collection.each do |resource|
      expect(resource.name).to match(/(^\/etc\/hosts$|^\/etc\/hosts\.(allow|deny)$)/)
    end
  end

  context 'with attributes' do

    context 'in sys.hosts.file' do
      before do
        chef_run.node.default['sys']['hosts']['file'] = {'ip' => 'host'}
        chef_run.converge(described_recipe)
      end

      it 'configures /etc/hosts' do
        expect(chef_run).to create_template('/etc/hosts')
      end
    end

    context 'in sys.hosts.allow' do
      before do
        chef_run.node.default['sys']['hosts']['allow'] = [ 'sshd: ALL' ]
        chef_run.converge(described_recipe)
      end

      it 'configures /etc/hosts.allow' do
        expect(chef_run).to create_template('/etc/hosts.allow')
        expect(chef_run).to render_file('/etc/hosts.allow')
                              .with_content('sshd: ALL')
      end
    end

    context 'in sys.hosts.deny' do
      before do
        chef_run.node.default['sys']['hosts']['deny'] = [ 'ALL: PARANOID' ]
        chef_run.converge(described_recipe)
      end

      it 'configures /etc/hosts.deny' do
        expect(chef_run).to create_template('/etc/hosts.deny')
        expect(chef_run).to render_file('/etc/hosts.deny')
                              .with_content('ALL: PARANOID')
      end
    end

  end

end
