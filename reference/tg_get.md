# Retrieve rows from a TransfereGov table

Queries one of the forty-eight tables published by the three
TransfereGov open data APIs and returns them as a tibble, with columns
typed from the API's own schema.

## Usage

``` r
tg_get(
  module,
  table,
  ...,
  .select = NULL,
  .order = NULL,
  .limit = 1000,
  .offset = 0,
  .page_size = 1000,
  .params = list(),
  .progress = NULL,
  .cache = NULL,
  .base_url = tg_base_url()
)

tg_obter(
  module,
  table,
  ...,
  .select = NULL,
  .order = NULL,
  .limit = 1000,
  .offset = 0,
  .page_size = 1000,
  .params = list(),
  .progress = NULL,
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

  Filters, named after the columns they apply to. See the Filters
  section.

- .select:

  Columns to return, as a character vector. `NULL`, the default, returns
  every column. Selecting fewer columns makes large queries markedly
  faster.

- .order:

  Sort order, as a character vector of column names, each optionally
  suffixed with `.asc` or `.desc`, and optionally with `.nullsfirst` or
  `.nullslast`. `NULL` uses the default order described under
  Pagination.

- .limit:

  Maximum number of rows to return. Use `Inf` for every matching row.

- .offset:

  Number of matching rows to skip before the first one returned.

- .page_size:

  Rows per request, between 1 and 1000.

- .params:

  Extra query parameters passed to the API verbatim, as a named list.
  This is the escape hatch for 'PostgREST' features the package does not
  model, such as
  `list(or = "(aa_ano_plano_acao.eq.2024,\ aa_ano_plano_acao.eq.2025)")`.

- .progress:

  Whether to show a progress bar while collecting pages. `NULL` shows
  one in interactive sessions when more than one page is needed.

- .cache:

  Whether to serve the request from the response cache. `NULL` follows
  the `transferegovr.cache` option. See
  [`tg_cache_dir()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_dir.md).

- .base_url:

  The API base URL. Defaults to
  [`tg_base_url()`](https://strategicprojects.github.io/transferegovr/reference/tg_base_url.md).

## Value

A tibble.
[`tg_metadata()`](https://strategicprojects.github.io/transferegovr/reference/tg_metadata.md)
reports the totals the API gave and how many pages were fetched.

## Filters

Name each filter after the column it applies to and give it a value or
an operator from
[`tg_operators()`](https://strategicprojects.github.io/transferegovr/reference/tg_operators.md).
A bare value means "equals", a bare vector means "is one of", and a list
of operators applies several conditions to the same column:

    tg_get("ted", "plano_acao", aa_ano_plano_acao = 2024)
    tg_get("ted", "plano_acao", aa_ano_plano_acao = c(2024, 2025))
    tg_get(
      "ted", "plano_acao",
      dt_inicio_vigencia = list(gte("2024-01-01"), lt("2025-01-01"))
    )

Column names and categorical values are in Portuguese because they
belong to the API. Use
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md)
to see them.

## Pagination

The service returns at most 1000 rows per request, whatever is asked of
it, so `.limit` above that is met by fetching successive pages. `.limit`
counts rows, not pages; use `Inf` for every matching row. Several tables
hold hundreds of thousands of rows, so check the size with
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md)
first.

Pages are fetched with an explicit `.order` because offset pagination
over an unordered query has no defined row order and could repeat or
skip rows. The default order is the table's primary key when the API
declares one, and its identifier columns otherwise. The number of rows
collected is checked against the total the API reports, and a mismatch
is reported as a warning.

## See also

Other queries:
[`module_shortcuts`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md),
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md),
[`tg_metadata()`](https://strategicprojects.github.io/transferegovr/reference/tg_metadata.md)

## Examples

``` r
if (interactive()) {
  tg_get("ted", "plano_acao", aa_ano_plano_acao = gte(2024), .limit = 50)

  tg_get(
    "fundoafundo", "plano_acao",
    .select = c("id_plano_acao", "vl_total_plano_acao"),
    .order = "vl_total_plano_acao.desc",
    .limit = 10
  )
}
```
