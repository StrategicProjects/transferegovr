# List the tables a module publishes

List the tables a module publishes

## Usage

``` r
tg_tables(module = NULL, counts = FALSE)

tg_tabelas(modulo = NULL, contagens = FALSE)
```

## Arguments

- module:

  A module name from
  [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md).
  Aliases such as `"fundo_a_fundo"` are accepted. `NULL` lists the
  tables of every module.

- counts:

  If `TRUE`, adds a `rows` column with the number of rows each table
  currently holds. This is the only part of this function that needs a
  network connection: it makes one request per table, so
  `tg_tables(counts = TRUE)` with no module makes seventy-four.
  Responses are cached.

- modulo:

  Portuguese alias for `module`, available in `tg_tabelas()` and
  [`tg_campos()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md).

- contagens:

  Portuguese alias for `counts`, available only in `tg_tabelas()`.

## Value

A tibble with one row per table: its module, name, the endpoint path it
maps to, its number of columns and filterable parameters, and the
description published in the API schema. With `counts = TRUE`, also the
current number of rows.

## See also

Other discovery:
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md),
[`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
[`tg_params()`](https://strategicprojects.github.io/transferegovr/reference/tg_params.md),
[`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md),
[`tg_updated_at()`](https://strategicprojects.github.io/transferegovr/reference/tg_updated_at.md)

## Examples

``` r
tg_tables("parcerias")
#> # A tibble: 17 × 6
#>    module    table                              path  columns params description
#>    <chr>     <chr>                              <chr>   <int>  <int> <chr>      
#>  1 parcerias analise_proposta                   anal…       7      5 Retorna um…
#>  2 parcerias beneficiario_emenda_parlamentar    bene…      16     14 Retorna um…
#>  3 parcerias cronograma_desembolso              cron…       7      7 Retorna um…
#>  4 parcerias distribuicao_recurso_proposta      dist…       9      9 Retorna um…
#>  5 parcerias documento_habil                    docu…      15     15 Retorna um…
#>  6 parcerias empenho_parceria                   empe…      24     24 Retorna um…
#>  7 parcerias extrato_bancario                   extr…      13     13 Retorna um…
#>  8 parcerias indicacao_beneficiario_emenda_par… indi…       5      5 Retorna um…
#>  9 parcerias item_proposta                      item…      14     13 Retorna um…
#> 10 parcerias meta_proposta                      meta…       6     13 Retorna um…
#> 11 parcerias opp                                opp        12     12 Retorna um…
#> 12 parcerias ordem_pagamento                    orde…      11     11 Retorna um…
#> 13 parcerias parceria                           parc…      18     24 Retorna um…
#> 14 parcerias parceria_conta                     parc…      23     28 Retorna um…
#> 15 parcerias programa                           prog…      51     52 Retorna um…
#> 16 parcerias proposta                           prop…      43     45 Retorna um…
#> 17 parcerias proposta_resultado_indicador       prop…       6      6 Retorna um…
tg_tables()
#> # A tibble: 74 × 6
#>    module    table                              path  columns params description
#>    <chr>     <chr>                              <chr>   <int>  <int> <chr>      
#>  1 especiais beneficiarios_especiais            bene…       5      5 Retorna um…
#>  2 especiais devolucao_especiais                devo…      22     22 Retorna um…
#>  3 especiais documentos_habeis_especiais        docu…      25     25 Retorna um…
#>  4 especiais empenhos_especiais                 empe…      24     24 Retorna um…
#>  5 especiais executores_especiais               exec…      17     17 Retorna um…
#>  6 especiais finalidade_especiais               fina…       5      5 Retorna um…
#>  7 especiais gestao_financeira_lancamentos_esp… gest…      34     30 Retorna um…
#>  8 especiais gestao_financeira_subtransacoes_e… gest…      14     12 Retorna um…
#>  9 especiais meta_especiais                     meta…      16     16 Retorna um…
#> 10 especiais ordens_pagamentos_ordens_bancaria… orde…      13     13 Retorna um…
#> # ℹ 64 more rows

if (interactive()) {
  # How big is everything, largest first?
  sizes <- tg_tables(counts = TRUE)
  sizes[order(-sizes$rows), ]
}
```
