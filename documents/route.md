Add and remove routing configurations.

↪ `attributes/route.rb`  
↪ `recipe/root.rb`  
↪ `test/roles/sys_roote_test.rb`

This recipe wraps the `route` resource provided.

**Attributes**

Attributes in `node.sys.route` need to contain a key defining the route target with the following configuration:

- **gateway** (required) – Gateway IP address.
- **netmask** (optional) – Target network netmask.
- **device** (optional) – Associated network interface (e.g. `eth0`).
- **delete** – If `true` removes defined network route.

**Examples**

    :sys => {
      :route => {
        '10.1.1.10' => {
          :gateway => '10.1.1.20',
          :device => 'eth0'
        },
        '10.1.3.0' => {},
        '10.1.2.0' => {
          :gateway => '10.1.1.15',
          :netmask => '255.255.255.0'
        },
        '10.0.2.0' => {
          :gateway => '10.1.1.15',
          :delete => true
        }
      }
    }



