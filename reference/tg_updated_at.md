# When a module's data was last refreshed

Each module publishes the timestamp of its last load. It is the only
freshness signal these APIs give: they send no `ETag`, `Cache-Control`
or `Last-Modified` header.

## Usage

``` r
tg_updated_at(module, .cache = NULL, .base_url = NULL)

tg_atualizado_em(module, .cache = NULL, .base_url = NULL)
```

## Arguments

- module:

  A module name from
  [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md):
  `"especiais"`, `"fundoafundo"` or `"parcerias"`. Aliases such as
  `"fundo_a_fundo"` are accepted.

- .cache:

  Whether to serve the request from the response cache. `NULL` follows
  the `transferegovr.cache` option. See
  [`tg_cache_dir()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_dir.md).

- .base_url:

  The API base URL. Defaults to
  [`tg_base_url()`](https://strategicprojects.github.io/transferegovr/reference/tg_base_url.md).

## Value

A `POSIXct` in UTC.

## See also

Other discovery:
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md),
[`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
[`tg_params()`](https://strategicprojects.github.io/transferegovr/reference/tg_params.md),
[`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md),
[`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)

## Examples

``` r
if (interactive()) {
  tg_updated_at("parcerias")
}
```
