describe 'sys::mount' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.mount is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    before do
      chef_run.node.default['sys']['mount']['/opt'] = {
        :device => '/dev/sdb1', :fstype => 'ext4', :action => [ :enable, :mount ]
      } 
      chef_run.node.default['sys']['mount']['/network'] = {
        :device => 'lxfs01.devops.test:/export', 
        :fstype => 'nfs', 
        :options => ['ro','nosuid'],
        :action => [ :enable, :mount ]
      } 
      chef_run.converge(described_recipe)
    end

    it 'mounts /opt and enables it in /etc/fstab' do
      expect(chef_run).to enable_mount('/opt')
      expect(chef_run).to mount_mount('/opt').with_device('/dev/sdb1')
    end

    it 'mounts /network' do
      expect(chef_run).to mount_mount('/network').with_fstype('nfs')
    end

  end

end
