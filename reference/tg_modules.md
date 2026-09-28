# List the TransfereGov API modules

List the TransfereGov API modules

## Usage

``` r
tg_modules()

tg_modulos()
```

## Value

A tibble with one row per module: its name, the label used in this
documentation, the number of tables it publishes, the largest page it
serves in one request, and its API base URL.

## See also

Other discovery:
[`tg_fields()`](https://strategicprojects.github.io/transferegovr/reference/tg_fields.md),
[`tg_params()`](https://strategicprojects.github.io/transferegovr/reference/tg_params.md),
[`tg_schema_date()`](https://strategicprojects.github.io/transferegovr/reference/tg_schema_date.md),
[`tg_tables()`](https://strategicprojects.github.io/transferegovr/reference/tg_tables.md),
[`tg_updated_at()`](https://strategicprojects.github.io/transferegovr/reference/tg_updated_at.md)

## Examples

``` r
tg_modules()
#> # A tibble: 4 × 5
#>   module      label                  tables max_page_size url                   
#>   <chr>       <chr>                   <int>         <int> <chr>                 
#> 1 especiais   Special transfers          23           200 https://api-publica.t…
#> 2 fundoafundo Fund-to-fund transfers     20          1000 https://api-publica.t…
#> 3 parcerias   Partnerships               17           200 https://api-publica.t…
#> 4 ted         Decentralized credit       14          1000 https://api-publica.t…
```
