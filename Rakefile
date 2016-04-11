begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |task|
    task.options = ['--lint']
  end
rescue LoadError
end

begin
  require 'foodcritic'
  FoodCritic::Rake::LintTask.new do |task|
    task.options = {
      :exclude_paths => ['example_config/**/*']
    }
  end
rescue LoadError
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:chefspec) do |task|
    task.pattern = 'test/unit/**/*.rb'
  end
rescue LoadError
end

task default: [:rubocop, :foodcritic, :chefspec]
