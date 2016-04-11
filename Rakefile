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

task default: [:rubocop, :foodcritic]
