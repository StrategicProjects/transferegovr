# List the parameters a table accepts as filters

Every parameter may be passed to
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
and
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md)
as a named argument. Parameter names and their permitted values are in
Portuguese because they belong to the API.

## Usage

``` r
tg_params(module, table)

tg_parametros(modulo, tabela)
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
  and
  [`tg_campos()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md).

- tabela:

  Portuguese alias for `table`, available only in
  [`tg_campos()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md).

## Value

A tibble with one row per parameter: its name, the R type a value should
have, the type the API declares, the permitted values when the parameter
is enumerated, the pattern a value must match when it has one, its
description, whether it accepts several values (`multiple`), and how
many at most (`max_values`).

## See also

Other discovery:
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md),
[`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
[`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md),
[`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md),
[`tg_updated_at()`](https://strategicprojects.github.io/transferegovr/reference/tg_updated_at.md)

## Examples

``` r
tg_params("parcerias", "proposta")
#> # A tibble: 45 × 8
#>    param          r_type api_type values pattern description multiple max_values
#>    <chr>          <chr>  <chr>    <list> <chr>   <chr>       <lgl>         <int>
#>  1 id_proposta    chara… string   <chr>  NA      Identifica… TRUE            200
#>  2 id_programa    chara… string   <chr>  NA      Identifica… TRUE            200
#>  3 cnpj_ente_rec… chara… string   <chr>  ^[0-9]… CNPJ do en… FALSE             1
#>  4 nm_ente_receb… chara… string   <chr>  NA      Nome compl… FALSE             1
#>  5 ed_cep         chara… string   <chr>  ^[0-9]… CEP do end… FALSE             1
#>  6 ed_logradouro  chara… string   <chr>  NA      Logradouro… FALSE             1
#>  7 ed_numero      chara… string   <chr>  NA      Número do … FALSE             1
#>  8 ed_complemento chara… string   <chr>  NA      Complement… FALSE             1
#>  9 ed_bairro      chara… string   <chr>  NA      Bairro do … FALSE             1
#> 10 cd_ibge_receb… double integer  <chr>  NA      Código IBG… FALSE             1
#> # ℹ 35 more rows

# Which parameters accept only a fixed set of values?
params <- tg_params("parcerias", "proposta")
params[lengths(params$values) > 0, c("param", "values")]
#> # A tibble: 5 × 2
#>   param                  values    
#>   <chr>                  <list>    
#> 1 sg_uf_recebedor        <chr [27]>
#> 2 situacao_proposta      <chr [5]> 
#> 3 in_situacao_analise    <chr [4]> 
#> 4 in_formato_etapas      <chr [3]> 
#> 5 in_tipo_prazo_captacao <chr [2]> 

# Which accept several values at once?
params[params$multiple, c("param", "max_values")]
#> # A tibble: 3 × 2
#>   param                       max_values
#>   <chr>                            <int>
#> 1 id_proposta                        200
#> 2 id_programa                        200
#> 3 id_programa_unidade_gestora        200
```
