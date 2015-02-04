describe 'sys::accounts' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
    end.converge(described_recipe)
  end

  context 'node.sys.accounts is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do

    it 'installs package ruby-shadow' do
      chef_run.node.default['sys']['accounts'] = { :not => "empty" }
      chef_run.converge(described_recipe)
      expect(chef_run).to install_package('ruby-shadow')
    end

    it 'manages groups' do
      @g1 = { 'gid' => 1337 }
      @g2 = {}
      chef_run.node.default['sys']['groups']['g1'] = @g1
      chef_run.node.default['sys']['groups']['g2'] = @g2
      chef_run.converge(described_recipe)
      expect(chef_run).to create_group('g1').with_gid(1337)
      expect(chef_run).to create_group('g2')
    end

    it 'manages users' do
      @u1 = {
        'uid'      => 666,
        'gid'      => 'fauxhai',
        'shell'    => '/bin/zsh',
        'home'     => '/home/u1',
        'comment'  => 'You have failed me for the last time',
        'password' => '$asdf',
        'system'   => true,
        'supports' => { 'manage_home' => true }
      }
      @u2 = { 'gid' => 0 } # the fauxhai group has gid 0
      @u4 = { 'gid' => 'doesnotexist' }
      chef_run.node.default['sys']['accounts']['u1'] = @u1
      chef_run.node.default['sys']['accounts']['u2'] = @u2
      chef_run.node.default['sys']['accounts']['u4'] = @u4
      chef_run.converge(described_recipe)
      expect(chef_run).to create_user('u1').with({
        :uid => @u1['uid'],
        :gid => @u1['gid'],
        :home => @u1['home'],
        :shell => @u1['shell'],
        :password => @u1['password'],
        :comment => @u1['comment'],
        :supports => @u1['supports'],
        :system => @u1['system']
      })
      expect(chef_run).to create_user('u2')
      expect(chef_run).to_not create_user('u4')
    end

    it 'honors manage_home flag' do
      @u3 = { 'supports' => { 'manage_home' => true } }
      chef_run.node.default['sys']['accounts']['u3'] = @u3
      chef_run.converge(described_recipe)
      expect(chef_run).to create_user('u3').with_supports(@u3['supports'])
    end

  end
end

describe 'sys::accounts_db' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new do |node, server|
      node.default['sys']['accounts']['v1'] = { }
      @v2 = { 'gid' => 1337 }
      node.default['sys']['accounts']['v2'] = @v2

      @v1item = {
        'id' => 'v1',
        'account' => {
          'home' => '/home/v1'
        }
      }
      @v2item = {
        'id' => 'v2',
        'account' => {
          'gid' => 'shouldnotbeseen',
          'home' => '/home/v2'
        }
      }

      server.create_data_bag('accounts', {
        'v1' => @v1item,
        'v2' => @v2item
      })
      server.create_data_bag('localgroups', { })
    end.converge(described_recipe)
  end

  context 'with accounts data bag' do

    it 'manages users from data bags' do
      expect(chef_run).to create_user('v2').with_home(@v2item['account']['home']).with_gid(@v2['gid'])
    end

    it 'derive manage_home from data_bags' do
      expect(chef_run).to create_user('v1').with_supports({ 'manage_home' => true })
    end

  end
end
