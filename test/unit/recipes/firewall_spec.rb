#
# Cookbook Name:: sys
# Unit tests for sys::firewall
#
# Copyright 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
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

describe 'sys::firewall' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  context 'node.sys.ferm.table is empty' do
    before do
      chef_run.converge(described_recipe)
    end

    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some rules' do
    before do
      chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:OUTPUT] = [
        'policy ACCEPT;',
        'mod state state (ESTABLISHED RELATED) ACCEPT;'
      ]
      chef_run.converge(described_recipe)
    end

    it 'upgrades package nftables' do
      expect(chef_run).to install_package('nftables')
    end

    it 'manages /etc/nftables.conf' do
      expect(chef_run).to create_template('/etc/nftables.conf').with_mode('0644').with_owner('root').with_group('adm')
      template = chef_run.template('/etc/nftables.conf')
      expect(template).to notify('service[nftables]').to(:reload).immediately
    end

    it 'enables and starts service "nftables"' do
      expect(chef_run).to enable_service('nftables')
      expect(chef_run).to start_service('nftables')
    end
  end

  context "with node['sys']['firewall']['active'] == false" do
    before do
      chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:OUTPUT] = [
        'policy ACCEPT;',
        'mod state state (ESTABLISHED RELATED) ACCEPT;'
      ]
      chef_run.node.default['sys']['firewall']['active'] = false
      chef_run.converge(described_recipe)
    end

    it 'disables and stops service "nftables"' do
      expect(chef_run).to disable_service('nftables')
      expect(chef_run).to stop_service('nftables')
    end
  end
end
