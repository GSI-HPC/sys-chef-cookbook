# The pci attribute is provided by the pci ohai plugin, but we install this
# plugin via chef. So, let's set a default to avoid problems before the plugin
# is deployed.
default_unless['pci'] = Mash.new
