describe 'sys::popcon' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'without any attributes' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end
  
  context 'with some test attributes' do
    let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['sys_popcon']) }

    before do
      chef_run.node.default['sys']['popcon']['enable'] = true
      chef_run.converge(described_recipe)
    end

    it "installs package" do
      expect(chef_run).to install_package('popularity-contest')
    end

    it "creates config file" do
      expect(chef_run).to render_file('/etc/popularity-contest.conf')
                           .with_content(/^PARTICIPATE="yes"$/)
                           .with_content(/^MY_HOSTID="[0-9a-f]{32}"$/)
                           .with_content(/^DAY="[0-6]"$/)
    end

  end

end
