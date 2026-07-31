# Count the rows a query matches

Asks the API for the number of rows matching a set of filters without
retrieving them. Worth doing before a large
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md):
the biggest table in these APIs holds over a million rows, which is more
than a thousand requests.

## Usage

``` r
tg_count(
  module,
  table,
  ...,
  .params = list(),
  .cache = NULL,
  .base_url = tg_base_url()
)

tg_contar(
  module,
  table,
  ...,
  .params = list(),
  .cache = NULL,
  .base_url = tg_base_url()
)
```

## Arguments

- module:

  A module name from
  [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md):
  `"transferenciasespeciais"`, `"fundoafundo"` or `"ted"`. Aliases such
  as `"fundo_a_fundo"` are accepted.

- table:

  A table name from
  [`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md).

- ...:

  Filters, named after the columns they apply to. See
  [`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md).

- .params:

  Extra query parameters passed to the API verbatim, as a named list.
  This is the escape hatch for 'PostgREST' features the package does not
  model, such as
  `list(or = "(aa_ano_plano_acao.eq.2024,\ aa_ano_plano_acao.eq.2025)")`.

- .cache:

  Whether to serve the request from the response cache. `NULL` follows
  the `transferegovr.cache` option. See
  [`tg_cache_dir()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_dir.md).

- .base_url:

  The API base URL. Defaults to
  [`tg_base_url()`](https://strategicprojects.github.io/transferegovr/reference/tg_base_url.md).

## Value

A single number.

## See also

Other queries:
[`module_shortcuts`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md),
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md),
[`tg_metadata()`](https://strategicprojects.github.io/transferegovr/reference/tg_metadata.md)

## Examples

``` r
if (interactive()) {
  tg_count("ted", "plano_acao")
  tg_count("ted", "plano_acao", aa_ano_plano_acao = 2024)
}
```
