#
# Ohai plugin for lsi controllers
#
# WORK IN PROGRESS
#


megacli = `MegaCli64 -AdpAllInfo -aALL`

megacli.split(/\s+(Adapter #\d)\n\n=+\n/m)[2].split(/ +([^\n]+)\n +=+\n/m)
