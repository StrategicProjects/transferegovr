# Retrieve rows from a TransfereGov table

Queries one of the fifty-five tables published by the TransfereGov open
data APIs and returns them as a tibble, with columns typed from the
API's own schema.

## Usage

``` r
tg_get(
  module,
  table,
  ...,
  .limit = 1000,
  .offset = 0,
  .page_size = 200,
  .progress = NULL,
  .cache = NULL,
  .base_url = NULL
)

tg_obter(
  module,
  table,
  ...,
  .limit = 1000,
  .offset = 0,
  .page_size = 200,
  .progress = NULL,
  .cache = NULL,
  .base_url = NULL
)
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

  Filters, named after the parameters they set. See the Filters section.

- .limit:

  Maximum number of rows to return. Use `Inf` for every matching row.

- .offset:

  Number of matching rows to skip before the first one returned.

- .page_size:

  Rows per request, between 1 and 200.

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
reports the totals the API gave and how many pages were fetched. A
column the API sends as an array of objects comes back as a list column;
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md)
describes what is inside it.

## Filters

Name each filter after one of the table's query parameters and give it a
single value. Parameters are combined with AND:

    tg_get("parcerias", "proposta", situacao_proposta = "Aprovada")
    tg_get(
      "parcerias", "proposta",
      sg_uf_recebedor = "PE", ano_proposta = 2025
    )

The services compare for equality and nothing else: there is no
greater-than, no pattern match and no "is one of". A parameter takes one
value, so query each value and bind the results when you need several.

Parameter names, and the permitted values of the enumerated ones, are in
Portuguese because they belong to the API. Use
[`tg_params()`](https://strategicprojects.github.io/transferegovr/reference/tg_params.md)
to see them. A name the packaged schema does not know is an error rather
than a request: these services ignore a parameter they do not recognize
and answer with the whole table, so an unchecked typo would return
plausible, wrong data.

## Pagination

The services return at most 200 rows per request, so `.limit` above that
is met by fetching successive pages. `.limit` counts rows, not pages;
use `Inf` for every matching row. Several tables hold hundreds of
thousands of rows, so check the size with
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md)
first.

Row order is the server's and cannot be set: these APIs publish no
ordering parameter. It was checked to be stable across page sizes,
across repeated calls and at depth, which is what makes multi-page
collection safe. The number of rows collected is checked against the
total the API reports, and a mismatch is reported as a warning.

## See also

Other queries:
[`module_shortcuts`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md),
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md),
[`tg_metadata()`](https://strategicprojects.github.io/transferegovr/reference/tg_metadata.md)

## Examples

``` r
if (interactive()) {
  tg_get("parcerias", "proposta", sg_uf_recebedor = "PE", .limit = 50)

  tg_get("fundoafundo", "planos_acao", .limit = 10)
}
```
