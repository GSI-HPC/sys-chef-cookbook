actions :set, :clear, :restore_default
default_action :restore_default

attribute :flag,
          kind_of: String,
          required: true
attribute :disk,
          kind_of: String,
          name_attribute: true,
          required: true
