describe 'sys::svn' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'without any attributes' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['sys_svn']) }

    before do
      chef_run.node.default['sys']['svn'] = {
        store_plaintext_passwords: true
      }
      chef_run.converge(described_recipe)
    end

    it "installs package" do
      expect(chef_run).to install_package('subversion')
    end

    it "creates /etc/subversion/servers" do
      expect(chef_run).to render_file('/etc/subversion/servers')
                           .with_content(/^store-plaintext-passwords = yes$/)
    end
  end

  context 'with proxy definitions' do
    let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['sys_svn']) }

    before do
      chef_run.node.default['sys']['http_proxy'] = {
        host: 'proxy.example.com',
        port: 8888
      }
      chef_run.node.default['sys']['svn']['proxy'] = {
        exceptions: '*.localdomain',
      }
      chef_run.converge(described_recipe)
    end

    it "creates /etc/subversion/servers" do
      expect(chef_run).to render_file('/etc/subversion/servers')
                           .with_content(/^http-proxy-host\s+=\s+proxy\.example\.com$/)
                           .with_content(/^http-proxy-exceptions\s+=\s+\*\.localdomain$/)
    end

  end

end
