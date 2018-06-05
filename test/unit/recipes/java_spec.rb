require 'chefspec'

describe 'sys::java' do

  cached(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  context 'without attributes' do
    it 'does nothing' do
      expect(chef_run.run_context.resource_collection).to be_empty
    end
  end

  context "with JRE onlys" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['java']['install_jdk'] = false
        node.default['sys']['java']['versions'] = [3, 17]
        node.default['sys']['java']['default_version'] = 666
      end.converge(described_recipe)
    end

    it 'installs jre' do
      expect(chef_run).to install_package('default-jre')
      expect(chef_run).to_not install_package('default-jdk')

      expect(chef_run).to install_package('openjdk-3-jre')
      expect(chef_run).to install_package('openjdk-17-jre')
      expect(chef_run).to run_execute('update-java-alternatives')
    end
  end

  context "with JDK attributes" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.default['sys']['java']['install_jdk'] = true
        node.default['sys']['java']['versions'] = [3, 17]
        node.default['sys']['java']['default_version'] = 666
      end.converge(described_recipe)
    end

    it 'installs jdk' do
      expect(chef_run).to install_package('default-jdk')

      expect(chef_run).to install_package('openjdk-3-jdk')
      expect(chef_run).to install_package('openjdk-17-jdk')
    end
  end

end
