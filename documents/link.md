
Use the Chef _link_ resource by attributes.

↪ `attributes/link.rb`  
↪ `recipes/link.rb`  
↪ `test/unit/recipies/link_spec.rb`  

# Examples

Use attributes in `node.sys.link`, e.g.:

    :sys => {
      :link => {
        '/tmp/cat' => {
          :to => '/bin/cat',
          :link_type => :symbolic,
          :mode => '0700'
        },
        '/tmp/foo => {
          :action => :delete
        }
      }
    }


