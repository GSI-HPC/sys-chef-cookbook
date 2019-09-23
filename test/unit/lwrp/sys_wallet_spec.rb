describe 'lwrp: sys_wallet' do
  let(:runner) do
    ChefSpec::SoloRunner.new(
      :step_into => ['sys_wallet'],
    ) do |n|
      n.default['sys']['krb5']['realm'] = 'example.com'
    end
  end

  describe 'action :deploy' do
    let(:chef_run) { runner.converge('fixtures::sys_wallet_deploy') }
    before do
      allow(File).to receive(:stat).and_call_original
      allow(File).to receive(:stat).with("/etc/krb5.keytab").and_return(::File.stat("/tmp"))
    end

    it 'deploys keytabs' do
      expect(chef_run).to run_bash('deploy host/node.example.com')
    end

    it 'changes permissions' do
      expect(chef_run).to create_file('/etc/krb5.keytab')
    end
  end
end
