name "sys_modules_test"
description "Use to test the [sys::modules] recipe."
run_list(
  'recipe[sys::fuse]',
  'recipe[sys::modules]' 
)
default_attributes(
  :sys => {
    :module => ['fuse']
  }
)
