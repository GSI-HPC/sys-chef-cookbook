require 'rubocop/rake_task'
RuboCop::RakeTask.new do |task|
  task.options = ['--lint']
end

require 'foodcritic'
FoodCritic::Rake::LintTask.new

task default: [:rubocop, :foodcritic]
