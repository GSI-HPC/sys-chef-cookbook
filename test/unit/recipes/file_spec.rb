describe 'sys::file' do

  cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'node.sys.file is empty' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context 'with some test attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['file'][@test_file] = {content: @test_file_content, mode: @test_file_mode}
      end.converge(described_recipe)
    end

    before do
      @test_file = '/tmp/file'
      @test_file_content = 'This is some plain text content'
      @test_file_mode = '0644'
    end

    it "Create #{@test_file} " do
      expect(chef_run).to create_file(@test_file).with(content: @test_file_content, mode: @test_file_mode)
    end
  end

  context 'with multiline content passed as Array' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['file'][@file]['content'] = @content
      end.converge(described_recipe)
    end

    before do
      @file = '/tmp/file'
      @content = [ 'line1', 'line2' ]
    end

    it "joins array" do
      expect(chef_run).to render_file(@file).with_content(@content.join("\n"))
    end
  end

  context 'with notification passed as Array' do
    let (:solo) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['file'][@file]['content'] = @content
        node.default['sys']['file'][@file]['notifies'] = @notification
      end
    end
    cached(:chef_run) do
      solo.converge(described_recipe) do
        solo.resource_collection.insert(
          Chef::Resource::Service.new(@service, solo.run_context)
        )
      end
    end

    before do
      @file = '/tmp/file'
      @content = 'some content'
      @service = 'dummy'
      @notification = [:restart, "service[#{@service}]", :delayed]
    end

    it "notifies" do
      expect(chef_run.file(@file)).to notify("service[#{@service}]").to(:restart).delayed
      expect(chef_run.service(@service)).to do_nothing # for test coverage
    end
  end
end
