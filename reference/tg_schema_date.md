# Report the frozen schema's build date

The package validates filters and types columns against a copy of the
APIs' OpenAPI documents taken on this date. A column added upstream
since then is still returned, but is typed by inspection rather than
from the schema.

## Usage

``` r
tg_schema_date()
```

## Value

A `Date`.

## See also

Other discovery:
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md),
[`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
[`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)

## Examples

``` r
tg_schema_date()
#> [1] "2026-07-31"
```
