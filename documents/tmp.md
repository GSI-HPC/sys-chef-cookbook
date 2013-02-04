Deploy a procedure to clean directories like `/tmp/`.

↪ `attributes/tmp.rb`  
↪ `recipes/tmp.rb`  
↪ `templates/*/tmpreaper.conf.erb`  
↪ `tests/roles/sys_tmp_test.rb`  

**Attributes**

All attributes in `node.sys.tmp`:

* `reaper` configures tmpreaper in `/etc/tmpreaper.conf` see manual.

Example:

    [...SNIP...]
    "sys" => {
      "tmp" => {
        "reaper" => {
          "max_age" => "8d",
          "protected_patterns" => [],
          "dirs" => ['/tmp/','/var/tmp'],
          "options" => '--runtime=1800'
        }
      }
      [...SNIP...]

