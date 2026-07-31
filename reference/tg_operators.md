# List the available filter operators

List the available filter operators

## Usage

``` r
tg_operators()

tg_operadores()
```

## Value

A tibble with the exported operator, the 'PostgREST' operator it sends,
and what it means.

## See also

Other filters:
[`filters`](https://strategicprojects.github.io/transferegovr/reference/filters.md)

## Examples

``` r
tg_operators()
#> # A tibble: 15 × 3
#>    operator  postgrest meaning                                     
#>    <chr>     <chr>     <chr>                                       
#>  1 eq        eq        equals                                      
#>  2 neq       neq       does not equal                              
#>  3 gt        gt        greater than                                
#>  4 gte       gte       greater than or equal to                    
#>  5 lt        lt        less than                                   
#>  6 lte       lte       less than or equal to                       
#>  7 like      like      matches pattern, case sensitive             
#>  8 ilike     ilike     matches pattern, case insensitive           
#>  9 re_match  match     matches regular expression, case sensitive  
#> 10 re_imatch imatch    matches regular expression, case insensitive
#> 11 in_       in        is one of                                   
#> 12 is_null   is.null   is null                                     
#> 13 is_true   is.true   is true                                     
#> 14 is_false  is.false  is false                                    
#> 15 not       not       negates another operator                    
```
