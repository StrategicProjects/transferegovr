# List the columns of a table

Column names stay in Portuguese because they are the API's own contract.
Not every column can be filtered on;
[`tg_params()`](https://strategicprojects.github.io/transferegovr/reference/tg_params.md)
lists the ones that can.

## Usage

``` r
tg_fields(module, table, nested = NULL)

tg_campos(modulo, tabela, nested = NULL)
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

- nested:

  The name of a list column, to describe the columns of the objects
  inside it instead of the table's own. `NULL`, the default, describes
  the table.

- modulo:

  Portuguese alias for `module`, available in
  [`tg_tabelas()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md)
  and `tg_campos()`.

- tabela:

  Portuguese alias for `table`, available only in `tg_campos()`.

## Value

A tibble with one row per column: its name, the R type the package
coerces it to, the type the API declares, the sub-schema it nests when
it is a list column, and its description.

## See also

Other discovery:
[`tg_modules()`](https://strategicprojects.github.io/transferegovr/reference/tg_modules.md),
[`tg_params()`](https://strategicprojects.github.io/transferegovr/reference/tg_params.md),
[`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md),
[`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md),
[`tg_updated_at()`](https://strategicprojects.github.io/transferegovr/reference/tg_updated_at.md)

## Examples

``` r
tg_fields("parcerias", "proposta")
#> # A tibble: 43 × 5
#>    field               r_type    api_type nested description                    
#>    <chr>               <chr>     <chr>    <chr>  <chr>                          
#>  1 id_proposta         double    integer  NA     Identificador único da propost…
#>  2 id_programa         double    integer  NA     Identificador do programa ao q…
#>  3 cnpj_ente_recebedor character string   NA     CNPJ do ente federativo ou ent…
#>  4 nm_ente_recebedor   character string   NA     Nome completo do ente ou entid…
#>  5 ed_cep              character string   NA     CEP do endereço do ente/entida…
#>  6 ed_logradouro       character string   NA     Logradouro do endereço do ente…
#>  7 ed_numero           character string   NA     Número do endereço do ente/ent…
#>  8 ed_complemento      character string   NA     Complemento do endereço do ent…
#>  9 ed_bairro           character string   NA     Bairro do endereço do ente/ent…
#> 10 cd_ibge_recebedor   double    integer  NA     Código IBGE do município do en…
#> # ℹ 33 more rows

# A list column, and what it holds
fields <- tg_fields("parcerias", "proposta")
fields[!is.na(fields$nested), c("field", "nested")]
#> # A tibble: 2 × 2
#>   field                       nested                          
#>   <chr>                       <chr>                           
#> 1 intervenientes_proposta     IntervenientePropostaEmbedded   
#> 2 categorias_despesa_proposta CategoriaDespesaPropostaEmbedded
tg_fields("parcerias", "proposta", nested = "intervenientes_proposta")
#> # A tibble: 2 × 5
#>   field              r_type    api_type nested description
#>   <chr>              <chr>     <chr>    <chr>  <chr>      
#> 1 cnpj_interveniente character string   NA     NA         
#> 2 nm_interveniente   character string   NA     NA         
```
