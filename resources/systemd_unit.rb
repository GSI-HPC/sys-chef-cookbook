actions :create, :delete, :enable, :disable, :start, :stop, :reload, :restart, :mask, :unmask
default_action [:create, :enable]

# name can be either just the name of the unit or name.type
attribute :name,
          kind_of: String,
          name_attribute: true,
          required: true
attribute :type,
          kind_of: [String, NilClass],
          default: nil,
          equal_to: [ 'service',
                      'socket',
                      'device',
                      'mount',
                      'automount',
                      'swap',
                      'target',
                      'path',
                      'timer',
                      'snapshot',
                      'slice',
                      'scope' ]
attribute :directory,
          kind_of: [String, NilClass],
          default: '/etc/systemd/system'
attribute :config,
          kind_of: Hash,
          required: true,
          default: {}
attribute :mode,
          kind_of: String,
          default: '0644'
attribute :owner,
          kind_of: String,
          default: 'root'
attribute :group,
          kind_of: String,
          default: 'root'
