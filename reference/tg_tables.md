# List the tables a module publishes

List the tables a module publishes

## Usage

``` r
tg_tables(module = NULL)

tg_tabelas(modulo = NULL)
```

## Arguments

- module:

  A module name from
  [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md).
  Aliases such as `"fundo_a_fundo"` are accepted. `NULL` lists the
  tables of every module.

- modulo:

  Portuguese alias for `module`, available only in `tg_tabelas()`.

## Value

A tibble with one row per table: its module, name, number of columns,
the primary key when the API declares one, and the description published
in the API schema.

## See also

Other discovery:
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md),
[`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
[`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md)

## Examples

``` r
tg_tables("ted")
#> # A tibble: 13 × 5
#>    module table                      columns primary_key description
#>    <chr>  <chr>                        <int> <chr>       <chr>      
#>  1 ted    evento                          10 NA          NA         
#>  2 ted    nota_credito                    11 NA          NA         
#>  3 ted    plano_acao                      20 NA          NA         
#>  4 ted    plano_acao_analise               5 NA          NA         
#>  5 ted    plano_acao_etapa                10 NA          NA         
#>  6 ted    plano_acao_meta                 10 NA          NA         
#>  7 ted    plano_acao_parecer               7 NA          NA         
#>  8 ted    programa                        24 NA          NA         
#>  9 ted    programa_acao_orcamentaria       3 NA          NA         
#> 10 ted    programa_beneficiario            4 NA          NA         
#> 11 ted    programacao_financeira          10 NA          NA         
#> 12 ted    termo_execucao                  10 NA          NA         
#> 13 ted    trf                              6 NA          NA         
tg_tables()
#> # A tibble: 48 × 5
#>    module                  table                 columns primary_key description
#>    <chr>                   <chr>                   <int> <chr>       <chr>      
#>  1 transferenciasespeciais documento_habil_espe…      23 id_dh       NA         
#>  2 transferenciasespeciais empenho_especial           27 NA          NA         
#>  3 transferenciasespeciais executor_especial          17 NA          Informaçõe…
#>  4 transferenciasespeciais finalidade_especial         5 NA          NA         
#>  5 transferenciasespeciais historico_pagamento_…       5 id_histori… NA         
#>  6 transferenciasespeciais meta_especial              16 NA          NA         
#>  7 transferenciasespeciais ordem_pagamento_orde…      13 id_op_ob    NA         
#>  8 transferenciasespeciais orgao_analise_penden…       4 NA          NA         
#>  9 transferenciasespeciais plano_acao_especial        27 id_plano_a… NA         
#> 10 transferenciasespeciais plano_trabalho_anali…      10 NA          NA         
#> # ℹ 38 more rows
```
