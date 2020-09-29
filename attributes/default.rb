# sensitive files created by this cookbook
#  will be readable to this group
default_unless['sys']['admin_group'] = 'root'
