require 'rubocop/rake_task'
RuboCop::RakeTask.new do |task|
  task.options = ['--lint']
end

require 'foodcritic'
FoodCritic::Rake::LintTask.new do |task|
  task.options = {
    :exclude_paths => ['example_config/**/*']
  }
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:chefspec) do |task|
  task.pattern = 'test/unit/**/*'
end

task default: [:rubocop, :foodcritic, :chefspec]
