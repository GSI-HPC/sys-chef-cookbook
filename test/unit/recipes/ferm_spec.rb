describe 'sys::ferm' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

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
      chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:OUTPUT] = [
        'policy ACCEPT;',
        'mod state state (ESTABLISHED RELATED) ACCEPT;'
      ]
      chef_run.converge(described_recipe)
    end

    it 'upgrades package ferm' do
      expect(chef_run).to install_package('ferm')
    end

    it 'manages /etc/ferm/ferm.conf' do
      expect(chef_run).to create_template('/etc/ferm/ferm.conf').with_mode('0644').with_owner('root').with_group('adm')
      template = chef_run.template('/etc/ferm/ferm.conf')
      expect(template).to notify('service[ferm]').to(:reload).immediately
    end

    it 'enables and starts service "ferm"' do
      expect(chef_run).to enable_service('ferm')
      expect(chef_run).to start_service('ferm')
    end
  end

  context 'with node.sys.ferm.active == false' do
    before do
      chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:OUTPUT] = [
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
      chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:OUTPUT] = [
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

  context 'sanity checks' do
    context 'composite domain' do
      it 'should let the composite domain pass' do
        chef_run.node.default[:sys][:ferm][:rules]['(ip ip6)'][:filter][:OUTPUT] = Array.new
        chef_run.converge(described_recipe)
        expect(chef_run).to render_file('/etc/ferm/ferm.conf').with_content('domain (ip ip6)')
      end
    end

    context 'illegal domain' do
      it 'should raise an exception' do
        chef_run.node.default[:sys][:ferm][:rules][:ip5][:filter][:OUTPUT] = Array.new
        expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Recipe::SysFermSanityCheckError, /^Insane ferm domain/)
      end
    end

    context 'composite table' do
      it 'should let the composite table pass' do
        chef_run.node.default[:sys][:ferm][:rules][:ip]['(filter nat)'][:OUTPUT] = Array.new
        chef_run.converge(described_recipe)
        expect(chef_run).to render_file('/etc/ferm/ferm.conf').with_content('table (filter nat)')
      end
    end

    context 'illegal table' do
      it 'should raise an exception' do
        chef_run.node.default[:sys][:ferm][:rules][:ip][:fitler][:OUTPUT] = Array.new
        expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Recipe::SysFermSanityCheckError, /^Insane ferm table/)
      end
    end

    context 'chain with underscore' do
      it 'should let the chain pass' do
        chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:INPU_T] = Array.new
        chef_run.converge(described_recipe)
        expect(chef_run).to render_file('/etc/ferm/ferm.conf').with_content('chain INPU_T')
      end
    end

    context 'illegal chain' do
      it 'should raise an exception' do
        chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:OUTPuT] = Array.new
        expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Recipe::SysFermSanityCheckError, /^Insane ferm chain/)
      end
    end

    context 'illegal rule' do
      it 'should raise an exception' do
        chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:INPUT] = [ ' asdf' ]
        expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Recipe::SysFermSanityCheckError, /^Insane ferm rule/)
      end
    end

    context 'comments' do
      it 'should let comments pass' do
        chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:INPUT] = [ '# asdf ' ]
        chef_run.converge(described_recipe)
        expect(chef_run).to render_file('/etc/ferm/ferm.conf').with_content('# asdf ')
      end
    end

    context 'empty lines' do
      it 'should let empty lines pass' do
        chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:INPUT] = [ '' ]
        expect { chef_run.converge(described_recipe) }.to_not raise_error
      end
    end

    context 'semicolon trailed rules' do
      it 'should let semicolon trailed rules pass' do
        chef_run.node.default[:sys][:ferm][:rules][:ip][:filter][:INPUT] = [ 'policy DROP;' ]
        chef_run.converge(described_recipe)
        expect(chef_run).to render_file('/etc/ferm/ferm.conf').with_content('policy DROP;')
      end
    end
  end
end
