actions :deploy
default_action :deploy

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
attribute :ignore_failure,
  kind_of: [TrueClass, FalseClass],
  default: false
