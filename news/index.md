# Changelog

## transferegovr 0.2.0

The package now targets the public API host,
`api-publica.transferegov.gestao.gov.br`. That host serves a different
kind of service from the ‘PostgREST’ one the package was built against,
so this release rewrites the client rather than extending it. Code
written against 0.1.0 will need changing.

### What is covered

- **`parcerias` is new**: partnership management, 15 tables, including
  88,666 partnerships and their proposals, budget commitments, payment
  orders and bank statements. It has no equivalent in the previous
  release.
- **`especiais` replaces `transferenciasespeciais`**, and grows from 14
  tables to 20. The additions are the financial ones: transaction
  entries, sub-entries, account balances, beneficiaries, and three
  history tables.
- **`fundoafundo` stays**, at 20 tables against the previous 21, with
  several child tables folded into their parents as nested columns.
- `"transferenciasespeciais"` still resolves, as an alias for
  `"especiais"`.
- **`ted` is gone.** Decentralized credit has not been published on the
  public API host; it exists only on the older service, which this
  package no longer uses. `tg_ted()` and `tg_transferencias_especiais()`
  are removed, and
  [`tg_parcerias()`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md)
  and
  [`tg_especiais()`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md)
  take their place alongside
  [`tg_fundo_a_fundo()`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md).

55 tables and 811 columns in all, against 48 and 599.

### Filters

- Filters are now the endpoints’ own typed query parameters rather than
  ‘PostgREST’ operators.
  [`tg_params()`](https://strategicprojects.github.io/transferegovr/reference/tg_params.md)
  lists what each table accepts, with the permitted values of the
  enumerated ones.
- **The comparison operators are removed** — `eq()`, `neq()`, `gt()`,
  `gte()`, `lt()`, `lte()`, `like()`, `ilike()`, `re_match()`,
  `re_imatch()`, `in_()`, `is_null()`, `is_true()`, `is_false()`,
  `not()` and `tg_operators()`. These services compare for equality and
  nothing else.
- **An unknown parameter name is an error.** These services ignore a
  parameter they do not recognize and answer `200` with the whole table,
  so a typo would return a plausible, unfiltered result. Names are
  checked against the frozen schema before the request is made, and a
  near miss is suggested.
- Enumerated values are checked client-side too, so a bad value fails
  before the round trip rather than as a 422 after it.
- A filter with several values, or a parameter given twice, is refused.
  The service keeps the last occurrence of a repeated parameter and
  discards the rest without reporting it, so there is no way to express
  either.

### Pagination

- Pagination is by page number, and the cap is 200 rows per request
  rather than
  1000. `.limit` still counts rows and `.offset` still counts rows,
        including when the offset falls inside a page.
- **`.order` and `.select` are removed.** These APIs publish no ordering
  or column-selection parameter.
- Row order is therefore the server’s. It was verified rather than
  assumed: the same rows come back in the same sequence across page
  sizes, across repeated calls, 100,000 rows deep, on tables with no
  key, and on tables with nested columns.

### Other changes

- [`tg_updated_at()`](https://strategicprojects.github.io/transferegovr/reference/tg_updated_at.md)
  reports when a module’s data was last loaded, from the
  `/data-atualizacao` endpoint each module publishes. It is the only
  freshness signal these APIs give.
- [`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md)
  gains a `nested` argument, describing the columns of the objects
  inside a list column. 18 columns across `fundoafundo` and `parcerias`
  arrive as list columns because the API folds a child table into its
  parent.
- [`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md)
  reports `api_type` rather than `pg_type`, and no longer reports a
  primary key: these documents declare none.
- [`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)
  gains `path`, the endpoint a table maps to, and `params`, how many
  filters it accepts. A table may be named with either a hyphen or an
  underscore.
- Integer columns are returned as double. These documents declare no
  `format`, so int32 and int64 cannot be told apart, and identifiers
  here genuinely exceed `.Machine$integer.max` — `cd_parceria` reaches
  202500037062.
- HTTP errors surface the validation detail the service reports, naming
  the parameter it objected to.

## transferegovr 0.1.0

First release.

- Covered the three ‘PostgREST’ TransfereGov open data APIs — special
  transfers (`transferenciasespeciais`), fund-to-fund transfers
  (`fundoafundo`) and decentralized credit (`ted`) — and the forty-eight
  tables they published.
- [`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
  and
  [`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md)
  queried any table; `tg_ted()`,
  [`tg_fundo_a_fundo()`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md)
  and `tg_transferencias_especiais()` fixed the module.
- Filters were named after the columns they applied to. A bare value
  meant “equals”, a bare vector meant “is one of”, and `tg_operators()`
  listed the fifteen comparison operators the services accepted.
- [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
  [`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)
  and
  [`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md)
  described the APIs offline, from a copy of their OpenAPI documents
  frozen into the package.
- Columns were typed from that schema rather than inferred.
- Pagination collected as many rows as `.limit` asked for, in pages of
  at most 1000 — the service’s own cap, which it applied silently. Every
  request carried an explicit order, so pages could not overlap or skip
  rows.
- Requests were throttled to sixty a minute and retried with exponential
  backoff on 429 and 5xx responses.
- Responses were cached for an hour, by default in the session’s
  temporary directory.
- English was canonical throughout, with Portuguese aliases for the
  exported verbs.
