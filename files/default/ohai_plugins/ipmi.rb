#
# Ohai plugin to check if IPMI HW is available.
#

Ohai.plugin(:Ipmi) do
  provides 'ipmi'
  depends 'kernel/modules'

  stamp_file = '/tmp/ohai_ipmi_check'

  collect_data(:default) do

    # Check if 'dmidecode' is available on the node:
    unless cmd_avail("dmidecode")
      Ohai::Log.debug("The dmidecode cmd is not available: " +
                      "no check for IPMI HW will be performed")
      false
    end

    # No IPMI modules loaded:
    unless kernel[:modules][:ipmi_si]
      # 1. Verify if there's IPMI HW available and we have not tried yet (stamp file)
      if ipmi_hw_avail and not File.exist?(stamp_file)
        # 2. Only if it's the case then we'll try to load IPMI modules.
        unless load_modules
          Ohai::Log.debug("IPMI modules could not be loaded")
        end
      end
    else
      # we have IPMI!: Fill the mash with the info from `bmc-config` etc:
      ipmi Mash.new
      ipmi['bmc-config'] = bmc_config
      ipmi['pef-config'] = pef_config
      ipmi['sensors-config'] = ipmi_config('ipmi-sensors').delete_if{ |_k,v|
        v.empty?
      }
    end
  end

  # Check if a command is available on the PATH:
  def cmd_avail(cmd)
    system("which #{ cmd} > /dev/null 2>&1")
  end

  # Attempt to verify if IPMI HW is available:
  #  Attention: false positives do occur ...
  def ipmi_hw_avail
    ipmi_available = ""
    # 38: DMI type for IPMI HW (cf. man dmidecode):
    result = shell_out('dmidecode -t 38')
    if result.exitstatus == 0
      result.stdout.lines do |line|
        case line
        when /IPMI Device Information/
          ipmi_available = "yes"
        end
      end

      if ipmi_available.eql?("yes")
        true
      end
    else
      false # No IPMI HW detect or non-zero exit status pf dmidecode.
    end
  end

  # Try to load the IPMI modules:
  def load_modules
    if shell_out('modprobe ipmi_devintf').exitstatus == 0
      if shell_out('modprobe ipmi_si').exitstatus == 0
        return File.exist?('/dev/ipmi0')
      end
    end
    FileUtils.touch(stamp_file)
    false
  end

  # Parse the output of bmc-config from freeipmi-tools:
  def ipmi_config(component = 'bmc')
    output = shell_out("#{component}-config --checkout")

    result = {}

    sections = Hash[output.stdout.scan(/^Section\s+(.*?)\s*\n+(.*?)EndSection/m)]

    sections.each do |name,config|
      h = {}
      config.each_line do |line|
        (key,value) = line.match(/^\s*(.*?)\s+(.*)/).captures
        next if key =~ /^#/   #skip comments
        h[key] = value
      end
      result[name] = h
    end

    return result
  end

  def bmc_config()
    # skip disabled users:
    ipmi_config.delete_if{|_k,v| v['Enable_User'] == 'No'}
  end

  def pef_config()

    h = ipmi_config('pef')

    # select enabled event filters:
    event_filters = h.select{ |k,v|
      k =~ /^Event_Filter_\d+$/ and
        v['Enable_Filter'] != 'No'
    }

    # TODO: aad alert destinations and strings that aren't mentioned in any
    #       event filter definition
    return h.select{ |k,_v|
      k == 'PEF_Conf' or k == 'Community_String'
    }.merge(event_filters)
  end

end
