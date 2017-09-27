describe 'sys::banner' do
  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context "node['sys']['banner']['message'] is empty" do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['banner']['message'] = 'example banner message'
        node.default['sys']['banner']['info'] = true
      end.converge(described_recipe)
    end

    it 'manages /etc/motd' do
      expect(chef_run).to create_template('/etc/motd').with_mode('0644')
    end

    it 'manages /etc/profile.d/info.sh' do
      expect(chef_run).to install_package('lsb-release')
      expect(chef_run).to create_template('/etc/profile.d/info.sh')
    end
  end

  context 'with Array as banner message' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        message = ['line1', 'line2']
        node.default['sys']['banner']['message'] = message
        @expected_message = message.join("\n")
      end.converge(described_recipe)
    end

    it 'prints all Strings in the Array on a seperate line' do
      expect(chef_run).to create_template('/etc/motd').with_variables(
        :header => chef_run.node['sys']['banner']['header'],
        :message => @expected_message,
        :service_properties => chef_run.node['sys']['banner']['service_properties'],
        :footer => chef_run.node['sys']['banner']['footer'])
    end
  end

  context 'with service_properties' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['banner']['message'] = 'asdf'
        node.default['sys']['banner']['service_properties'] = [ 'prop1', 'prop2' ]
      end.converge(described_recipe)
    end

    it 'renders a list of service_properties' do
      expect(chef_run).to render_file('/etc/motd').with_content(/ \* prop1\n \* prop2\n/)
    end
  end
end
