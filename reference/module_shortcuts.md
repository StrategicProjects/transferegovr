# Query a single module

Thin wrappers over
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
with the module fixed, for code that stays within one API.

## Usage

``` r
tg_ted(table, ...)

tg_fundo_a_fundo(table, ...)

tg_transferencias_especiais(table, ...)
```

## Arguments

- table:

  A table name from
  [`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)
  for that module.

- ...:

  Passed to
  [`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md):
  filters, and any of its `.`-prefixed arguments.

## Value

A tibble, as
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
returns.

## See also

Other queries:
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md),
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md),
[`tg_metadata()`](https://strategicprojects.github.io/transferegovr/reference/tg_metadata.md)

## Examples

``` r
if (interactive()) {
  tg_ted("plano_acao", .limit = 10)
  tg_fundo_a_fundo("programa", .limit = 10)
  tg_transferencias_especiais("programa_especial")
}
```
