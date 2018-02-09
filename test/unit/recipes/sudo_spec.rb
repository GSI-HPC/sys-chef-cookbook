describe 'sys::sudo' do
  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.sudo is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['sudo'] = {
          test: {
            users: {
              'TEST' => %w[regular with-minus]
            },
            rules: [ 'TEST ALL = ALL' ]
          }
        }
      end.converge(described_recipe)
    end

    it 'installs package sudo' do
      expect(chef_run).to install_package('sudo')
    end

    it 'manages file /etc/sudoers' do
      expect(chef_run).to create_template('/etc/sudoers').with(:mode => '0440')
    end

    it 'manages directory /etc/sudoers.d' do
      expect(chef_run).to create_directory('/etc/sudoers.d')
                           .with(:mode => '0755')
    end

    it 'manages file /etc/sudoers.d/test' do
      expect(chef_run).to create_template('/etc/sudoers.d/test')
                           .with(:mode => '0440')
    end

    it 'surrounds some users with double quotes' do
      expect(chef_run).to create_template('/etc/sudoers.d/test').with(
        :variables => { :name => 'test',
                        :users => { 'TEST' => [ 'regular', '"with-minus"' ] },
                        :hosts => {},
                        :commands => {},
                        :rules => [ 'TEST ALL = ALL' ] }
      )
      expect(chef_run).to render_file('/etc/sudoers.d/test')
                           .with_content('"with-minus"')
      expect(chef_run).to render_file('/etc/sudoers.d/test')
                           .with_content(' regular,')
    end
  end

  context 'with custom mail recipient' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['sudo'] = {
          config: {
            mailto: 'itsec@example.com'
          }
        }
      end.converge(described_recipe)
    end

    it 'sets mailto in /etc/sudoers' do
      expect(chef_run).to render_file('/etc/sudoers')
                           .with_content(/mailto="itsec@example.com"/)
    end
  end
end
