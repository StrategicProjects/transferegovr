# List the columns of a table

Every column name may be used as a filter in
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
and
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md),
in `.select`, and in `.order`. Column names and categorical values stay
in Portuguese because they are the API's own contract.

## Usage

``` r
tg_fields(module, table)

tg_campos(modulo, tabela)
```

## Arguments

- module:

  A module name from
  [`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md).
  Aliases such as `"fundo_a_fundo"` are accepted. `NULL` lists the
  tables of every module.

- table:

  A table name from
  [`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md).

- modulo:

  Portuguese alias for `module`, available in
  [`tg_tabelas()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)
  and `tg_campos()`.

- tabela:

  Portuguese alias for `table`, available only in `tg_campos()`.

## Value

A tibble with one row per column: its name, the R type the package
coerces it to, the Postgres type the API reports, whether it is part of
the declared primary key, and its description.

## See also

Other discovery:
[`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
[`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md),
[`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)

## Examples

``` r
tg_fields("ted", "plano_acao")
#> # A tibble: 20 × 5
#>    field                              r_type    pg_type  primary_key description
#>    <chr>                              <chr>     <chr>    <lgl>       <chr>      
#>  1 id_plano_acao                      double    bigint   FALSE       Identifica…
#>  2 id_programa                        double    bigint   FALSE       Identifica…
#>  3 sigla_unidade_descentralizada      character charact… FALSE       Sigla da U…
#>  4 unidade_descentralizada            character charact… FALSE       Unidade De…
#>  5 sigla_unidade_responsavel_execucao character charact… FALSE       Sigla da U…
#>  6 unidade_responsavel_execucao       character charact… FALSE       Unidade Re…
#>  7 vl_total_plano_acao                double    double … FALSE       Valor Tota…
#>  8 dt_inicio_vigencia                 Date      date     FALSE       Data do In…
#>  9 dt_fim_vigencia                    Date      date     FALSE       Data Final…
#> 10 tx_objeto_plano_acao               character charact… FALSE       Objeto do …
#> 11 tx_justificativa_plano_acao        character charact… FALSE       Justificat…
#> 12 in_forma_execucao_direta           logical   boolean  FALSE       Indicador …
#> 13 in_forma_execucao_particulares     logical   boolean  FALSE       Indicador …
#> 14 in_forma_execucao_descentralizada  logical   boolean  FALSE       Indicador …
#> 15 tx_situacao_plano_acao             character charact… FALSE       Situação d…
#> 16 aa_ano_plano_acao                  integer   smallint FALSE       Ano do Pla…
#> 17 vl_beneficiario_especifico         double    double … FALSE       Valor do B…
#> 18 vl_chamamento_publico              double    double … FALSE       Valor do C…
#> 19 sq_instrumento                     character charact… FALSE       Sequencial…
#> 20 aa_instrumento                     integer   integer  FALSE       Ano do Ins…
```
