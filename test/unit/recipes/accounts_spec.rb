#
# Cookbook Name:: sys
# Unit tests for recipe sys::accounts
#
# Copyright 2015-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn  <C.Huhn@gsi.de>
#  Dennis Klein      <d.klein@gsi.de>
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

describe 'sys::accounts' do

  context 'node.sys.accounts is empty' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do

    before do
      # group attributes
      @g1 = { 'gid' => 1337 }
      @g2 = {}

      # group data_bag:
      @g2item = {
        'id' => 'g2',
        'gid' => 'gidfromdatabag'
      }

      # user attributes:
      @u1 = {
        'uid' => 666,
        'gid' => 'fauxhai',
        'shell' => '/bin/zsh',
        'home' => '/home/u1',
        'password' => '$asdf',
        'manage_home' => true,
        'system' => true
      }
      @u2 = { 'password' => 'asdf' }
      @u3 = { 'gid' => 0 } # the fauxhai group has gid 0
      @u4 = { 'gid' => 1337 }
      @u5 = { 'home' => '/somewhere/overthere',
              'supports' => { manage_home: true } }
      @u6 = { 'gid' => 'doesnotexist' }

      # user data_bags:
      @u2item = {
        'id' => 'u2',
        'account' => {
          'home' => '/home/u2'
        }
      }
      @u4item = {
        'id' => 'u4',
        'account' => {
          'gid' => 'shouldnotbeseen',
          'home' => '/home/u4'
        }
      }
    end

    cached(:chef_run) do
      ChefSpec::ServerRunner.new(log_level: :fatal) do |node, server|
        node.default['sys']['groups']['g1'] = @g1
        node.default['sys']['groups']['g2'] = @g2
        node.default['sys']['accounts']['u1'] = @u1
        node.default['sys']['accounts']['u2'] = @u2
        node.default['sys']['accounts']['u3'] = @u3
        node.default['sys']['accounts']['u4'] = @u4
        node.default['sys']['accounts']['u5'] = @u5
        node.default['sys']['accounts']['u6'] = @u6
        server.create_data_bag('accounts', {
                                 'u2' => @u2item,
                                 'u4' => @u4item
                               })
        server.create_data_bag('localgroups', {
                                 'g2' => @g2item
                               })
        # trigger installation of ruby-shadow:
        node.automatic['chef_packages']['chef']['chef_root'] =
          '/usr/lib/ruby/vendor_ruby'
      end.converge(described_recipe)
    end

    it 'installs package ruby-shadow' do
      expect(chef_run).to install_package('ruby-shadow')
    end

    it 'manages groups' do
      expect(chef_run).to create_group('g1').with_gid(1337)
      expect(chef_run).to create_group('g2')
    end

    it 'manages users' do
      expect(chef_run).to create_user('u1')
      u1 = chef_run.find_resource(:user, 'u1')
      expect(u1.uid).to eq @u1['uid']
      expect(u1.gid).to eq @u1['gid']
      expect(u1.home).to eq @u1['home']
      expect(u1.shell).to eq @u1['shell']
      expect(u1.password).to eq @u1['password']
      expect(u1.comment).to eq 'managed by Chef via sys_accounts recipe'
      expect(u1.system).to eq @u1['system']
      expect(u1.manage_home).to be
      expect(chef_run).to create_user('u2')
      expect(chef_run).to create_user('u3')
      expect(chef_run).to create_user('u4')
      expect(chef_run).to create_user('u5')
      expect(chef_run).to_not create_user('u6')
    end

    it 'adds and honors :manage_home flag' do
      # has home attribute set in data bag
      expect(chef_run).to create_user('u2')
      u2 = chef_run.find_resource(:user, 'u2')
      expect(u2.manage_home).to be

      # has supports hash with manage_home (deprecated)
      expect(chef_run).to create_user('u5')
      u5 = chef_run.find_resource(:user, 'u5')
      expect(u5.manage_home).to be
    end

    it 'merges attributes with data bag item' do
      expect(chef_run).to create_user('u4')
                            .with_home(@u4item['account']['home'])
                            .with_gid(@u4['gid'])
      expect(chef_run).to create_group('g2').with_gid(@g2item['gid'])
    end
  end
end
