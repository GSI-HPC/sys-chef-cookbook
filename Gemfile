source 'http://rubygems.org'

group :development do
  gem 'rake'
  gem 'rubocop' #, '~> 0.49'
  # Foodcritic 13 drops Chef 12 compatibility:
  gem 'foodcritic', '< 13'
  # Newer versions break foodcritic:
  #  https://github.com/Foodcritic/foodcritic/commit/28f6684
  gem 'cucumber-core', '>= 1.3', '< 4.0'

  gem 'berkshelf'

  # take Chef version from environment, fall back to newest version:
  gem 'chef', (ENV['CHEF_VERSION']) ? "~> #{ENV['CHEF_VERSION']}" : "< 15"

  gem 'chefspec', '< 7.2'
  gem 'chefspec-ohai'

  # test-kitchen pulls Chef's crappy license-acceptance gem
  gem 'test-kitchen', '< 2.2'

  # gem 'guard-rspec', require: false
  # gem 'libnotify'
  # gem "serverspec"
end

group :travis do
  gem 'kitchen-docker'
end

group :vagrant do
  gem 'vagrant'
  gem 'kitchen-vagrant'
  gem 'vagrant-libvirt'
  gem 'vagrant-berkshelf'
end
