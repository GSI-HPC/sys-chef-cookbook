describe 'sys::hosts' do

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'check if all resources are present' do
    chef_run.run_context.resource_collection.each do |resource|
      expect(resource.name).to match(/(^\/etc\/hosts$|^\/etc\/hosts\.(allow|deny)$)/)
    end
  end

  context 'sys.hosts not empty' do

    context 'sys.hosts.file not empty' do
      before do
        chef_run.node.default['sys']['hosts']['file'] = {'ip' => 'host'}
        chef_run.converge(described_recipe)
      end

      it 'configures /etc/hosts' do
        expect(chef_run).to create_template('/etc/hosts')
      end
    end

    context 'sys.hosts.allow not empty' do
      before do
        chef_run.node.default['sys']['hosts']['allow'] = {'ALL' => 'ALL'}
        chef_run.converge(described_recipe)
      end

      it 'configures /etc/hosts.allow' do
        expect(chef_run).to create_template('/etc/hosts.allow')
      end
    end

    context 'sys.hosts.deny not empty' do
      before do
        chef_run.node.default['sys']['hosts']['deny'] = {'ALL' => 'ALL'}
        chef_run.converge(described_recipe)
      end

      it 'configures /etc/hosts.deny' do
        expect(chef_run).to create_template('/etc/hosts.deny')
      end
    end

  end

end
