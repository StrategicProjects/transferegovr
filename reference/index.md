# Package index

## Queries

Retrieving rows from the three TransfereGov APIs.

- [`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
  [`tg_obter()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
  : Retrieve rows from a TransfereGov table
- [`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md)
  [`tg_contar()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md)
  : Count the rows a query matches
- [`tg_ted()`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md)
  [`tg_fundo_a_fundo()`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md)
  [`tg_transferencias_especiais()`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md)
  : Query a single module
- [`tg_metadata()`](https://strategicprojects.github.io/transferegovr/reference/tg_metadata.md)
  [`tg_metadados()`](https://strategicprojects.github.io/transferegovr/reference/tg_metadata.md)
  : Inspect what a query retrieved

## Filters

The comparison operators the APIs accept. Each topic also lists its
Portuguese alias, which shares the same help page.

- [`eq()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`neq()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`gt()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`gte()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`lt()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`lte()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`like()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`ilike()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`re_match()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`re_imatch()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`in_()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`is_null()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`is_true()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`is_false()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  [`not()`](https://strategicprojects.github.io/transferegovr/reference/filters.md)
  : Filter operators
- [`tg_operators()`](https://strategicprojects.github.io/transferegovr/reference/tg_operators.md)
  [`tg_operadores()`](https://strategicprojects.github.io/transferegovr/reference/tg_operators.md)
  : List the available filter operators

## Discovery

What the APIs publish, without making a request.

- [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md)
  [`tg_modulos()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md)
  : List the TransfereGov API modules
- [`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)
  [`tg_tabelas()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)
  : List the tables a module publishes
- [`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md)
  [`tg_campos()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md)
  : List the columns of a table
- [`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md)
  : Report the frozen schema's build date

## Configuration

Caching and connection settings.

- [`tg_cache_dir()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_dir.md)
  [`tg_cache_pasta()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_dir.md)
  : Where cached responses are stored
- [`tg_cache_clear()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_clear.md)
  [`tg_cache_limpar()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_clear.md)
  : Delete cached responses
- [`tg_base_url()`](https://strategicprojects.github.io/transferegovr/reference/tg_base_url.md)
  : The API base URL in use
