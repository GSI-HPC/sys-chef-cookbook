begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |task|
    task.options = ['--lint']
  end
rescue LoadError
  desc 'rubocop rake task not available'
  task :rubocop do
    abort 'Rubocop rake task is not available. Be sure to install rubocop'
  end
end

begin
  require 'foodcritic'
  FoodCritic::Rake::LintTask.new do |task|
    task.options = {
      :exclude_paths => ['example_config/**/*']
    }
  end
rescue LoadError
  desc 'foodcritic rake task not available'
  task :foodcritic do
    abort 'Foodcritic rake task is not available. Be sure to install foodcritic'
  end
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:chefspec) do |task|
    task.pattern = 'test/unit/**/*_spec.rb'
    task.rspec_opts = '--backtrace --color --format documentation --require spec_helper -I libraries --default-path test/unit'
  end
rescue LoadError
  desc 'chefspec rake task not available'
  task :chefspec do
    abort 'Chefspec rake task is not available. Be sure to install chefspec'
  end
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new do
    Kitchen.logger = Kitchen.default_logger
  end
rescue LoadError
  desc 'kitchen rake task not available'
  task :kitchen do
    abort 'kitchen rake task is not available. Be sure to install test-kitchen'
  end
end

task default: [:rubocop, :foodcritic, 'kitchen:all']
