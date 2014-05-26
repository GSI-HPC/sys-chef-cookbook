require 'chefspec'

describe 'sys::ferm' do
  let(:chef_run) { ChefSpec::Runner.new }

  context 'node.sys.ferm.table is empty' do
    before do
      chef_run.converge(described_recipe)
    end

    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some rules in filter.OUTPUT' do
    before do
      chef_run.node.default[:sys][:ferm][:table][:filter][:OUTPUT] = [
        'policy ACCEPT;',
        'mod state state (ESTABLISHED RELATED) ACCEPT;'
      ]
      chef_run.converge(described_recipe)
    end

    it 'upgrades package ferm' do
      expect(chef_run).to upgrade_package('ferm')
    end

    it 'manages /etc/ferm/ferm.conf' do
      expect(chef_run).to create_template('/etc/ferm/ferm.conf').with_mode('0644').with_owner('root').with_group('adm')
    end

    it 'enables and starts service "ferm"' do
      expect(chef_run).to enable_service('ferm')
      expect(chef_run).to start_service('ferm')
    end
  end

  context 'with node.sys.ferm.active == false' do
    before do
      chef_run.node.default[:sys][:ferm][:table][:filter][:OUTPUT] = [
        'policy ACCEPT;',
        'mod state state (ESTABLISHED RELATED) ACCEPT;'
      ]
      chef_run.node.default[:sys][:ferm][:active] = false
      chef_run.converge(described_recipe)
    end

    it 'disables and stops service "ferm"' do
      expect(chef_run).to disable_service('ferm')
      expect(chef_run).to stop_service('ferm')
    end
  end

  context 'with node.sys.ferm.foreign_config == true' do
    before do
      chef_run.node.default[:sys][:ferm][:table][:filter][:OUTPUT] = [
        'policy ACCEPT;',
        'mod state state (ESTABLISHED RELATED) ACCEPT;'
      ]
      chef_run.node.default[:sys][:ferm][:foreign_config] = true
      chef_run.converge(described_recipe)
    end

    it 'does not manage /etc/ferm/ferm.conf' do
      expect(chef_run).to_not render_file('/etc/ferm/ferm.conf')
    end
  end
end
