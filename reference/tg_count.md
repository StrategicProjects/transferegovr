# Count the rows a query matches

Asks the API for the number of rows matching a set of filters without
retrieving them. Worth doing before a large
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md):
the biggest table in these APIs holds over a million rows, which at 200
rows a request is more than five thousand requests.

## Usage

``` r
tg_count(module, table, ..., .cache = NULL, .base_url = NULL)

tg_contar(module, table, ..., .cache = NULL, .base_url = NULL)
```

## Arguments

- module:

  A module name from
  [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md):
  `"especiais"`, `"fundoafundo"` or `"parcerias"`. Aliases such as
  `"fundo_a_fundo"` are accepted.

- table:

  A table name from
  [`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md).

- ...:

  Filters, named after the parameters they set. See
  [`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md).

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
  tg_count("parcerias", "proposta")
  tg_count("parcerias", "proposta", situacao_proposta = "Aprovada")
}
```
