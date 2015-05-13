Ohai.plugin(:Pci) do
  provides 'pci'

  collect_data(:default) do
    pci Array.new
    `lspci -m`.split("\n").each do |line|
       line = line.split(' "').map { |e| e.delete('"') }
       pci << {
         'slot' => line[0],
         'type' => line[1],
         'vendor' => line[2],
         'device' => line[3][0..-6] # cut the revision number
       }
    end
  end
end
