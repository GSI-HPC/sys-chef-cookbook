# More info at https://github.com/guard/guard#readme

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^recipes/(.+)\.rb$}) { |m| "spec/unit/recipes/#{m[1]}_spec.rb" }
  watch(%r{^attributes/(.+)\.rb$}) { |m| "spec/unit/recipes/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
