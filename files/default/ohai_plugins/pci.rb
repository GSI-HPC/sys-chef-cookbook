#
# gather a list of PCI devices with lspci
#

Ohai.plugin(:Pci) do
  provides 'pci'
  provides 'pci2'

  collect_data(:default) do
    pci []
    `lspci -m`.each_line do |line|
      line = line.split(' "').map { |e| e.delete('"') }
      pci << {
        'slot' => line[0],
        'type' => line[1],
        'vendor' => line[2],
        'device' => line[3][0..-6] # cut the revision number
      }
    end

    # Hashes are more suitable for searching with `knife search`:
    pci2 Mash.new
    # use the more verbose lspci output:
    # devices are split by double newlines
    #  -vmm: output format
    #    -k: add kernel driver
    #   -nn: add numeric PCI ids
    `lspci -vmm -k -nn`.split("\n\n").each do |d|
      # each device is a list of "key1:\tvalue1\nkey2:..."
      # we scan this into [ [ 'key1', 'value1' ], [ ... ] ]
      a = d.scan(/^(.*?):\t(.*?)$/)
      # make the keys lowercase and turn result into a hash
      h = a.map { |k, v| [k.downcase, v] }.to_h
      # remove the 'slot' and use it as the key for the pci2 hash
      key = h.delete('slot')
      pci2[key] = h
    end
  end
end
