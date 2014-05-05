require 'chefspec'

describe 'sys::apt' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    @apt_update = 'apt-get -qq update'
  end

  it 'has an execute resource for apt-get update' do
    res = chef_run.find_resource(:execute, @apt_update)
    expect(res).to do_nothing
  end

  context 'node.sys.apt is empty' do
    it 'does not add multiarch support' do
      res = chef_run.find_resource(:execute, 'dpkg --add-architecture i386')
      expect(res).to do_nothing
    end

    it 'does nothing else' do
      all = chef_run.run_context.resource_collection.all_resources
      expect(all.size).to eq(2)
      expect(all[0].command).to eq('apt-get -qq update')
      expect(all[1].command).to eq('dpkg --add-architecture i386')
    end
  end

  context 'node.sys.apt.packages is not empty' do
    before do
      chef_run.node.default['sys']['apt']['packages'] = [ 'example' ]
      chef_run.converge(described_recipe)
    end

    it 'installs packages' do
      expect(chef_run).to install_package('example')
    end
  end

  context 'node.sys.apt.keys is not empty' do
    let(:chef_run) {ChefSpec::Runner.new(step_into: ['sys_apt_key']) }

    before do
      stub_command('apt-key list | grep samplekey1 >/dev/null').and_return(true)
      chef_run.node.default['sys']['apt']['keys']['remove'] = ['samplekey1']
      chef_run.node.default['sys']['apt']['keys']['add'] = ['samplekey2']
      chef_run.converge(described_recipe)
    end

    it 'manages APT keys (remove first, then add)' do
      expect(chef_run).to remove_sys_apt_key('samplekey1')
      expect(chef_run).to add_sys_apt_key('samplekey2')

      # check the order
      add = chef_run.find_resource(:sys_apt_key, 'samplekey2')
      remove = chef_run.find_resource(:sys_apt_key, 'samplekey1')
      add_index = chef_run.run_context.resource_collection.all_resources.index(add)
      remove_index = chef_run.run_context.resource_collection.all_resources.index(remove)
      expect(add_index).to be > remove_index
    end
  end

  context 'node.sys.apt.repositories is not empty' do
    let(:chef_run) {ChefSpec::Runner.new(log_level: :error, step_into: ['sys_apt_repository']) }

    before do
      chef_run.node.default['sys']['apt']['repositories']['foo'] = 'bar'
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/apt/sources.list.d/*' do
      expect(chef_run).to add_sys_apt_repository('foo')

      file = '/etc/apt/sources.list.d/foo.list'
      res = chef_run.find_resource(:template, file)
      expect(res).to notify("execute[#{@apt_update}]").to(:run).immediately
      expect(chef_run).to create_template(file)
    end
  end

  context 'node.sys.apt.preferences is not empty' do
    let(:chef_run) {ChefSpec::Runner.new(log_level: :error, step_into: ['sys_apt_preference']) }

    before do
      chef_run.node.default['sys']['apt']['preferences']['foopref'] = {
        'package' => 'foobar',
        'pin' => 'version 666',
        'priority' => 1001
      }
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/apt/preferences.d/*' do
      expect(chef_run).to set_sys_apt_preference('foopref').with_package('foobar').with_pin('version 666').with_priority(1001)

      file = '/etc/apt/preferences.d/foopref'
      res = chef_run.find_resource(:template, file)
      expect(res).to notify("execute[#{@apt_update}]").to(:run).immediately
      expect(chef_run).to create_template(file).with_mode('0644').with_variables({
        :name => 'foopref',
        :package => 'foobar',
        :pin => 'version 666',
        :priority => 1001
      })
      expect(chef_run).to render_file(file).with_content('Package: foobar')
    end
  end

  context 'node.sys.apt.config is not empty' do
    let(:chef_run) {ChefSpec::Runner.new(log_level: :error, step_into: ['sys_apt_conf']) }

    before do
      chef_run.node.default['sys']['apt']['config']['fooconf'] = { 'foo' => 'bar' }
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/apt/apt.conf.d/*' do
      expect(chef_run).to set_sys_apt_conf('fooconf')

      file = '/etc/apt/apt.conf.d/fooconf'
      res = chef_run.find_resource(:template, file)
      expect(res).to notify("execute[#{@apt_update}]").to(:run).immediately
      expect(chef_run).to create_template(file).with_mode('0644')
    end
  end
end
