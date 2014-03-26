require 'chefspec'

describe 'sys::banner' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  context 'node.sys.banner.message is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    before do
      chef_run.node.default['sys']['banner']['message'] = 'example banner message'
      chef_run.node.default['sys']['banner']['info'] = true
      chef_run.converge(described_recipe)
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
    before do
      message = ['line1', 'line2']
      chef_run.node.default['sys']['banner']['message'] = message
      chef_run.converge(described_recipe)
      @expected_message = message.join("\n")
    end

    it 'prints all Strings in the Array on a seperate line' do
      expect(chef_run).to create_template('/etc/motd').with_variables(
        :header => chef_run.node.sys.banner.header,
        :message => @expected_message,
        :service_properties => chef_run.node.sys.banner.service_properties,
        :footer => chef_run.node.sys.banner.footer)
    end
  end

  context 'with service_properties' do
    before do
      chef_run.node.default['sys']['banner']['message'] = 'asdf'
      chef_run.node.default['sys']['banner']['service_properties'] = [ 'prop1', 'prop2' ]
      chef_run.converge(described_recipe)
    end

    it 'renders a list of service_properties' do
      expect(chef_run).to render_file('/etc/motd').with_content(/ \* prop1\n \* prop2\n/)
    end
  end
end
