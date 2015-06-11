default_unless['sys']['systemd'] = Mash.new
default_unless['sys']['systemd']['networkd'] = Mash.new
default_unless['sys']['systemd']['networkd']['enable'] = false
default_unless['sys']['systemd']['networkd']['clean_legacy'] = false
default_unless['sys']['systemd']['unit'] = Mash.new
