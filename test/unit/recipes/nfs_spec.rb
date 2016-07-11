describe 'sys::nfs' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.nfs is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with krb5 enabled' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    before do
      chef_run.node.default['sys']['nfs']['krb5'] = true
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/default/nfs-common' do
      expect(chef_run).to create_template('/etc/default/nfs-common').with_mode('0644')
    end

    it 'enables services via /etc/default/nfs-common' do
      expect(chef_run).to render_file('/etc/default/nfs-common').with_content('NEED_IDMAPD="yes"')
      expect(chef_run).to render_file('/etc/default/nfs-common').with_content('NEED_GSSD="yes"')
    end
  end

  context 'without krb5 enabled' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    before do
      chef_run.node.default['sys']['nfs']['krb5'] = false
      chef_run.converge(described_recipe)
    end

    it 'manages /etc/default/nfs-common' do
      expect(chef_run).to create_template('/etc/default/nfs-common').with_mode('0644')
    end

    it 'enables services via /etc/default/nfs-common' do
      expect(chef_run).to render_file('/etc/default/nfs-common').with_content('NEED_IDMAPD=')
      expect(chef_run).to render_file('/etc/default/nfs-common').with_content('NEED_GSSD=')
    end
  end
end
