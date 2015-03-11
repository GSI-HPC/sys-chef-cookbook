
Use the Chef file resource by attributes.

↪ `attributes/file.rb`  
↪ `recipes/file.rb`  
↪ `test/unit/recipies/file_spec.rb`  

# Examples

Use attributes in `node.sys.file`, e.g.:

    :sys => {
      :file => {
        '/tmp/test_file' => {
          :content => 'This is some plain text content',
          :mode => '0644'
        }
      }
    }


