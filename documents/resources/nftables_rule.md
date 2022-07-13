# sys_nftables_rule

[Back to resource list](../README.md#resources)

## Provides

- :nftables_rule

## Actions

- `:create`

## Properties

| Name                   | Name? | Type                                  | Default     | Description                                                         | Allowed Values                                                                       |
| ---------------------- | ----- | ----------------------                | --------    | ----------                                                          | --------------------                                                                 |
| `nftables_name`        |       | `String`                              | `'default'` | Must match the name of the `nftables`-resource. Do not change this. |                                                                                      |
| `command`              |       | `Symbol`                              | `:allow`    |                                                                     | `:accept`, `:allow`, `:deny`, `:drop`, `:log`, `:masquerade`, `:redirect`, `:reject` |
| `protocol`             |       | `Integer`, Symbol                     | `:tcp`      |                                                                     |                                                                                      |
| `direction`            |       | `Symbol`                              | `:in`       |                                                                     | `:in`, `:out`, `:pre`, `:post`, `:forward`                                           |
| `logging`              |       | `Symbol`                              |             |                                                                     | `:connections`, `:packets`                                                           |
| `family`               |       | `Symbol`                              | `:ip`       |                                                                     | `:ip6`, `:ip`                                                                        |
| `source`               |       | `String`, `Array`                     |             |                                                                     |                                                                                      |
| `sport`                |       | `Integer`, `String`, `Array`, `Range` |             |                                                                     |                                                                                      |
| `interface`            |       | `String`                              |             |                                                                     |                                                                                      |
| `dport`                |       | `Integer`, `String`, `Array`, `Range` |             |                                                                     |                                                                                      |
| `destination`          |       | `String`, `Array`                     |             |                                                                     |                                                                                      |
| `outerface`            |       | `String`                              |             |                                                                     |                                                                                      |
| `position`             |       | `Integer`                             | `50`        | Lower values will put the rule further up in `/etc/nftables.conf`   |                                                                                      |
| `stateful`             |       | `Symbol`, `Array`                     |             |                                                                     |                                                                                      |
| `redirect_port`        |       | `Integer`                             |             |                                                                     |                                                                                      |
| `description`          | ✓     | `String`                              |             |                                                                     |                                                                                      |
| `include_comment`      |       | `true`, `false`                       | `true`      | If `true`, will add description as comment to the rule              |                                                                                      |
| `raw`                  |       | `String`                              |             |                                                                     |                                                                                      |
| `notify_nftables`      |       | `true`, `false`                       | `true`      | If `false`, the rule will not be evaluated.                         |                                                                                      |
