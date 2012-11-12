actions :reboot, :shutdown
default_action :shutdown
attribute :time, :kind_of => String , :name_attribute => true
attribute :message, :kind_of => String, 
  :default => "Unscheduled maintenance intervention. We apologize for trouble caused."
