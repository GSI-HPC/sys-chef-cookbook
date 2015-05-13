
The `sys_sdparm` lwrp:

↪ `attributes/sdparm.rb`  
↪ `recipes/sdparm.rb`  
↪ `resources/sdparm.rb`  
↪ `providers/sdparm.rb`  
↪ `test/unit/recipes/sdparm_spec.rb`  

# Examples

Use attributes in `node.sys.sdparm`, e.g.:

    'sys' => {
      'sdparm' => {
        'set' => { # <-- action
        # flag     disks
          'WCE' => [ '/dev/sd*' ]
        }
      }
    }

Possible actions are `set`, `clear` and `restore_defaults`.

Query e.g. `sdparm --all --long /dev/sda` to see possible values for flag.

The disk parameter is an absolute device path, usage of shell wildcards is possible.

