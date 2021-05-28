actions :deploy
default_action node['sys']['wallet']['default_action'] ? node['sys']['wallet']['default_action'].to_sym : :deploy

attribute :owner,
  kind_of: String,
  default: "root"
attribute :group,
  kind_of: String,
  default: "root"
attribute :mode,
  kind_of: String,
  default: "0600"
attribute :place,
  kind_of: String,
  required: true
attribute :principal,
  kind_of: String,
  name_attribute: true
