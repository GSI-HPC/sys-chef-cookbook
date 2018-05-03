require Mixlib::ShellOut

Ohai.plugin(:LsiController) do

  provides 'lsi'

  def capabilities_to_hash(section)
    ret = Mash.new
    section.elements[1].elements.each do |e|
      ret[e.elements[0].text_value.strip] = e.elements[2].text_value.strip
    end
    section.elements[3].elements[3].elements.each do |e|
      ret['allowed_mixing'] ||= []
      ret['allowed_mixing'] += [e.text_value.strip]
    end
    return ret
  end

  def pci_info_to_hash(section)
    ret = Mash.new
    section.elements[1].elements.each do |e|
      next if e.text_value.strip.empty?
      key = e.elements[0].text_value.strip
      value = e.elements[2].text_value.strip
      ret[key] = value unless key == 'Port' && value == 'Address'
    end

    addresses = Mash.new
    section.elements[2].elements.each do |e|
      addresses[e.elements[0].text_value] = e.elements[2].text_value
    end
    ret['port_address'] = addresses
    return ret
  end

  def pending_images_in_flash_to_hash(section)
    section.elements[1].text_value
  end

  def default_settings_to_hash(section)
    ret = Mash.new
    section.elements[1].elements.each do |e|
      ret[e.elements[0].text_value.strip] = e.elements[2].text_value.strip
    end

    section.elements[4].elements.each do |e|
      ret[e.elements[0].text_value.strip] = e.elements[2].text_value.strip
    end
    return ret
  end

  collect_data(:default) do
    require 'open3'
    require 'treetop'

    cmd = '/usr/sbin/MegaCli64 -AdpAllInfo -aALL'

    status = shell_out(cmd).stdout

    Treetop.load("#{File.dirname(__FILE__)}/lsi.treetop")
    parser = DetailParser.new
    parsed = parser.parse status

    lsi Mash.new
    parsed.elements[1].elements.each do |adapter|
      adp_string = "Adapter_#{adapter.elements[0].elements[1].text_value}"
      lsi[adp_string] = Mash.new
      adapter.elements[1..-1].each do |section|
        sct_string = section.elements[0].elements[1].text_value.strip.downcase.gsub(/[^a-z0-9]/, '_').gsub(/_{2,}/, '_').gsub(/_\z/, '')
        case sct_string
        when /version/, /mfg_data/, /\Asettings\z/, /status/, /limitations/, /device_present/, /supported_adapter_operations/, /supported_vd_operations/, /supported_pd_operations/, /error_counters/, /cluster_information/, /hw_configuration/
          lsi[adp_string][sct_string] = Mash.new
          section.elements[1].elements.each do |kv|
            next if kv.text_value.strip.empty?
            lsi[adp_string][sct_string][kv.elements[0].text_value.strip] = kv.elements[2].text_value.strip
          end
        when /capabilities/
          lsi[adp_string][sct_string] = capabilities_to_hash(section)
        when /pci_info/
          lsi[adp_string][sct_string] = pci_info_to_hash(section)
        when /pending_images_in_flash/
          lsi[adp_string][sct_string] = pending_images_in_flash_to_hash(section)
        when /default_settings/
          lsi[adp_string][sct_string] = default_settings_to_hash(section)
        else
          next
        end
      end
    end
  end
end
