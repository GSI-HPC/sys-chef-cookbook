# More info at https://github.com/guard/guard#readme
notification :libnotify, timeout: 5, transient: true, append: true, urgency: :normal
guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^recipes/(.+)\.rb$}) { |m| "spec/unit/recipes/#{m[1]}_spec.rb" }
  watch(%r{^attributes/(.+)\.rb$}) { |m| "spec/unit/recipes/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch(%r{^templates/.+\.erb$})
  watch(%r{^files/})
  watch(%r{^resources/})
  watch(%r{^providers/})
  watch(%r{^libraries/})
end
