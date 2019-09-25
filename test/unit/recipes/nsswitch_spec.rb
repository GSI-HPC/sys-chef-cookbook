describe 'sys::nsswitch' do

  context "node['sys']['nsswitch'] is empty" do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['nsswitch']['asdf'] = '1qay'
        node.default['sys']['nsswitch']['protocols'] = 'nunc est bibendum'
      end.converge(described_recipe)
    end

    it 'adds defaults to nsswitch.conf' do
      expect(chef_run).to render_file('/etc/nsswitch.conf')
                            .with_content(/^passwd: +compat/)
                            .with_content(/^hosts: +files dns/)
    end

    it 'adds custom config to nsswitch.conf' do
      expect(chef_run).to render_file('/etc/nsswitch.conf')
                            .with_content(/^asdf: +1qay/)
    end

    it 'adds defaults to nsswitch.conf' do
      expect(chef_run).to render_file('/etc/nsswitch.conf')
                            .with_content(/^protocols: +nunc est bibendum/)
    end
  end
end
