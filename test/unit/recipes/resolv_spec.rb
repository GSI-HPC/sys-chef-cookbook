describe 'sys::resolv' do

  context "node['sys']['resolv']['servers'] is empty" do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'does nothing' do
      expect(chef_run.run_context.resource_collection
              .to_hash.keep_if { |x| x['updated'] }).to be_empty
    end
  end

  context 'with basic attributes' do
    before do
      allow(File).to receive(:symlink?).and_call_original
      allow(File).to receive(:symlink?).with('/etc/resolv.conf')
                       .and_return(false)
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['resolv']['servers'] =
          %w(1.2.3.4 5.6.7.8 9.10.11.12)
        node.default['sys']['resolv']['search']  = 'example.com'
      end.converge(described_recipe)
    end

    it 'creates /etc/resolv.conf' do
      expect(chef_run).to create_template('/etc/resolv.conf')
    end
  end

  context '/etc/resolv.conf is a symlink' do
    before do
      allow(File).to receive(:symlink).and_call_original
      allow(File).to receive(:symlink).with('/etc/resolv.conf')
                       .and_return(true)
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['resolv']['servers'] = %w(8.8.4.4 8.8.8.8)
      end.converge(described_recipe)
    end

    it 'emits a warning' do
      expect(chef_run).to write_log('resolv.conf-symlink')
    end

    it 'does not touch /etc/resolv.conf' do
      expect(chef_run).to_not create_template('/etc/resolv.conf')
    end
  end

  context 'both domain and search defined' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['resolv']['servers'] = %w(8.8.4.4 8.8.8.8)
        node.default['sys']['resolv']['search']  = "example.com t.example.com"
        node.default['sys']['resolv']['domain']  = "example.com"
      end.converge(described_recipe)
    end

    it 'emits a warning' do
      expect(chef_run).to write_log('domain+search')
    end
  end
end
