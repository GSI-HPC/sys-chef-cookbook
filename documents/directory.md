
Manage directories via attributes.

↪ `attributes/directory.rb`  
↪ `recipes/directory.rb`  
↪ `tests/roles/sys_directory_test.rb`  

# Examples

Use attributes in `node.sys.directory`, e.g.:

    "sys" => {
      "directory" => {
        "/uss/enterprise" => {
          "owner" => "root",
          "group" => "adm",
          "mode" => "0707",
          "recursive" => true
        },
        "/uss/voyager" => {
          "recursive" => true
        }
      }
    }


