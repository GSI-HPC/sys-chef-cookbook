# nftables

[Back to resource list](../../README.md#resources)

## Provides

- :nftables

## Actions

- `:install`
- `:rebuild`
- `:restart`
- `:disable`

## Properties

| Name                   | Name? | Type            | Default    | Description  | Allowed Values       |
| ---------------------- | ----- | ------------    | -------    | ------------ | -------------------- |
| `rules`                |       | `Hash`          | `{}`       |              |                      |
| `input_policy`         |       | `String`        | `'accept'` |              | `'drop'`, `'accept'` |
| `output_policy`        |       | `String`        | `'accept'` |              | `'drop'`, `'accept'` |
| `forward_policy`       |       | `String`        | `'accept'` |              | `'drop'`, `'accept'` |
| `table_ip_nat`         |       | `true`, `false` | `false`    |              |                      |
| `table_ip6_nat`        |       | `true`, `false` | `false`    |              |                      |
