# Inspect what a query retrieved

Inspect what a query retrieved

## Usage

``` r
tg_metadata(x)

tg_metadados(x)
```

## Arguments

- x:

  A tibble returned by
  [`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md).

## Value

A list holding the module and table queried, the total number of
matching rows the API reported, how many rows and pages were retrieved,
the offset, page size and filters used, and when the query ran. `NULL`
for any other object.

## See also

Other queries:
[`module_shortcuts`](https://strategicprojects.github.io/transferegovr/reference/module_shortcuts.md),
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md),
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)

## Examples

``` r
tg_metadata(tibble::tibble())
#> NULL
```
