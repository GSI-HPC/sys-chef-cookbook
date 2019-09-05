describe 'sys::sudo' do
  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.sudo is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    before do
      allow(::Dir).to receive(:glob).and_call_original
      allow(::Dir).to receive(:glob).with('/etc/sudoers.d/*')
                       .and_return(
                         %w[/etc/sudoers.d/delete_me /etc/sudoers.d/README]
                       )
    end

    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['sudo'] = {
          test: {
            users: {
              'TEST' => [ 'regular', 'with-minus' ]
            },
            rules: [ 'TEST ALL = ALL' ]
          },
          config: {
            cleanup: true,
            mailto: 'staatsanwaltschaft@example.com'
          }
        }
      end.converge(described_recipe)
    end

    it 'installs package sudo' do
      expect(chef_run).to install_package('sudo')
    end

    it 'manages file /etc/sudoers' do
      expect(chef_run).to create_template('/etc/sudoers').with(:mode => '0440')
      expect(chef_run).to delete_file('/etc/sudoers.d/delete_me')
      expect(chef_run).to_not delete_file('/etc/sudoers.d/README')
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
                            variables: {
                              users: {
                                'TEST' => [ 'regular', '"with-minus"' ]
                              },
                              hosts: {},
                              commands: {},
                              rules: [ 'TEST ALL = ALL' ]
                            }
                          )
      expect(chef_run).to render_file('/etc/sudoers.d/test')
                           .with_content('"with-minus"')
      expect(chef_run).to render_file('/etc/sudoers.d/test')
                           .with_content(' regular,')
    end

    it 'sets mailto in /etc/sudoers' do
      expect(chef_run).to render_file('/etc/sudoers')
                           .with_content(
                             /mailto="staatsanwaltschaft@example.com"/
                           )
    end
  end
end
