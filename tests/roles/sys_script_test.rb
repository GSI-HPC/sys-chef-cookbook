name "sys_script_test"
description "Use to test the [sys::script] recipe."
run_list( "recipe[sys::script]" )
default_attributes(
  sys: {
    script: {
      'Add user joe to /etc/passwd' => {
        interpreter: 'bash',
        code: 'echo "joe:x:2222:2222:JoeDown:/home/jdown:/bin/bash" >> /etc/passwd',
        not_if: 'grep ^joe: /etc/passwd >/dev/null'
      }
    }
  }
)
