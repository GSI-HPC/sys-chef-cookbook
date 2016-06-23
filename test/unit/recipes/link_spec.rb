describe 'sys::link' do

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.link is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do

    let(:chef_run) { ChefSpec::SoloRunner.new }

    before do
      @link_bash = '/tmp/link_to_bash'
      @link_cat = '/tmp/link_to_cat'

      chef_run.node.default['sys']['link'] = {
        @link_bash => { to: '/bin/bash' },
        @link_cat => { to: '/bin/cat', link_type: :symbolic }
      }
      chef_run.converge(described_recipe)
    end

    it "Create link #{@link_bash}" do
      expect(chef_run).to create_link(@link_bash)
    end

    it "Create link #{@link_cat}" do
      expect(chef_run).to create_link(@link_cat).with_link_type(:symbolic)
    end

  end

end
