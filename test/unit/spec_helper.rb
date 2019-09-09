require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start!

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks (default: [inferred from
  # the location of the calling spec file])
  #config.cookbook_path = "#{__dir__}/../../.."

  # Specify the path for Chef Solo to find roles (default: [ascending search])
  #config.role_path = '/var/roles'

  # Specify the Chef log_level (default: :warn)
  config.log_level = :warn

  # Specify the operating version to mock Ohai data from (default: nil)
  config.platform = 'debian'
  config.version  = '9.2'
end
