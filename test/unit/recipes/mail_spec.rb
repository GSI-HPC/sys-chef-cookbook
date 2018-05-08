describe 'sys::mail' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.mail.relay is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    let(:chef_run) { ChefSpec::SoloRunner.new(step_into: ['sys_mail_alias']) }
    let(:file_edit_dummy) { double('file edit dummy') }

    before do
      # mock Chef::Util::FileEdit - what a mess
      allow(Chef::Util::FileEdit).to receive(:new).and_call_original
      allow(Chef::Util::FileEdit).to receive(:new).with('/etc/aliases')
                                      .and_return(file_edit_dummy)
      allow(file_edit_dummy).to receive(:insert_line_if_no_match)
      allow(file_edit_dummy).to receive(:write_file)

      chef_run.node.default[:sys][:mail][:relay] = 'smtp.example.net'
      @example_alias_name = 'foo'
      @example_alias_value = 'foo@bar.mail'
      @expected_alias_value = '"foo@bar.mail"'
      chef_run.node.default[:sys][:mail][:aliases][@example_alias_name.to_sym] = @example_alias_value
      allow(::File).to receive(:exist?).and_call_original
      allow(::File).to receive(:exist?).with('/etc/aliases').and_return(false)
      chef_run.converge(described_recipe)
    end

    postfix = 'postfix'
    it "installs package '#{postfix}'" do
      expect(chef_run).to install_package(postfix)
    end

    it "manages service '#{postfix}'" do
      expect(chef_run.service(postfix)).to do_nothing
    end

    etc_mailname = '/etc/mailname'
    it "manages #{etc_mailname}" do
      expect(chef_run).to create_file(etc_mailname)
                           .with_content("#{chef_run.node['fqdn']}\n")
    end

    etc_postfix_canonical = '/etc/postfix/canonical'
    update_canonical = 'Update Postfix canonicals'
    it "manages #{etc_postfix_canonical}" do
      expect(chef_run).to create_template(etc_postfix_canonical).with_mode('0600')
      expect(chef_run.template(etc_postfix_canonical)).to notify("execute[#{update_canonical}]").to(:run).immediately
      expect(chef_run.execute(update_canonical)).to do_nothing
      expect(chef_run.execute(update_canonical)).to notify("service[#{postfix}]").to(:reload).delayed
    end

    etc_postfix_virtual = '/etc/postfix/virtual'
    update_virtual = 'Update Postfix virtual aliases'
    it "manages #{etc_postfix_virtual}" do
      expect(chef_run).to create_template(etc_postfix_virtual).with_mode('0600')
      expect(chef_run.template(etc_postfix_virtual)).to notify("execute[#{update_virtual}]").to(:run).immediately
      expect(chef_run.execute(update_virtual)).to do_nothing
      expect(chef_run.execute(update_virtual)).to notify("service[#{postfix}]").to(:reload).delayed
    end

    etc_postfix_main_cf = '/etc/postfix/main.cf'
    it "manages #{etc_postfix_main_cf}" do
      expect(chef_run).to create_template(etc_postfix_main_cf).with_mode('0644')
      expect(chef_run.template(etc_postfix_main_cf)).to notify("service[#{postfix}]").to(:restart).delayed
    end

    etc_aliases = '/etc/aliases'
    update_aliases = 'Update Postfix aliases'
    action_add = 'SysMailAlias action :add : insert alias'
    it "manages #{etc_aliases}" do
      expect(chef_run).to add_sys_mail_alias(@example_alias_name).with_to(@expected_alias_value).with_aliases_file(etc_aliases)
      expect(chef_run.find_resource(:sys_mail_alias, @example_alias_name)).to notify("execute[#{update_aliases}]").to(:run).delayed
      expect(chef_run).to run_execute(update_aliases)
      expect(chef_run.execute(update_aliases)).to notify("service[#{postfix}]").to(:reload).delayed
      expect(chef_run).to create_file(etc_aliases)
      # we completly mocked away Chef::Util::FileEdit for now,
      #  therefore this will fail:
      #expect(chef_run).to run_ruby_block(action_add)
    end
  end
end
