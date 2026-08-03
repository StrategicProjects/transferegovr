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
is enumerated, the pattern a value must match when it has one, and its
description.

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
#> # A tibble: 45 × 6
#>    param               r_type    api_type values    pattern          description
#>    <chr>               <chr>     <chr>    <list>    <chr>            <chr>      
#>  1 id_proposta         double    integer  <chr [0]> NA               Identifica…
#>  2 id_programa         double    integer  <chr [0]> NA               Identifica…
#>  3 cnpj_ente_recebedor character string   <chr [0]> ^[0-9]{14}       CNPJ do en…
#>  4 nm_ente_recebedor   character string   <chr [0]> NA               Nome compl…
#>  5 ed_cep              character string   <chr [0]> ^[0-9]{5}-[0-9]… CEP do end…
#>  6 ed_logradouro       character string   <chr [0]> NA               Logradouro…
#>  7 ed_numero           character string   <chr [0]> NA               Número do …
#>  8 ed_complemento      character string   <chr [0]> NA               Complement…
#>  9 ed_bairro           character string   <chr [0]> NA               Bairro do …
#> 10 cd_ibge_recebedor   double    integer  <chr [0]> NA               Código IBG…
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
```
