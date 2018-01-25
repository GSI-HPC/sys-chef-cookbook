describe 'sys::fuse' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  context 'attributes are empty' do
    before do
      chef_run.converge(described_recipe)
    end

    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context "with node['sys']['fuse']['config']" do
    before do
      chef_run.node.default['sys']['fuse']['config'] = {
        bli: 'blubb',
        bla: nil
      }
      chef_run.converge(described_recipe)
    end

    it 'installs fuse package' do
      expect(chef_run).to install_package('fuse')
    end

    it 'manages /etc/fuse.conf' do
      #expect(chef_run).to create_template('/etc/fuse.conf')
      #                     .with_mode('0644')
      #                     .with_owner('root')
      #                     .with_group('root')
      expect(chef_run).to render_file('/etc/fuse.conf')
                           .with_content('bli = blubb')
                           .with_content(/^bla$/)
    end

    #  context 'on Wheezy' do
    #    before do
    #      chef_run.converge(described_recipe)
    #    end

    #    it 'reloads udev' do
    #      expect(chef_run).to reload_service('fuse')
    #    end
    #  end

  end

end
