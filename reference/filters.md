# Filter operators

Constructors for the comparison operators the 'PostgREST' services
behind the TransfereGov APIs accept. Pass them as named arguments to
[`tg_get()`](https://strategicprojects.github.io/transferegovr/reference/tg_get.md)
or
[`tg_count()`](https://strategicprojects.github.io/transferegovr/reference/tg_count.md),
where the name is the column being filtered.

## Usage

``` r
eq(x)

neq(x)

gt(x)

gte(x)

lt(x)

lte(x)

like(pattern)

ilike(pattern)

re_match(pattern)

re_imatch(pattern)

in_(values)

is_null()

is_true()

is_false()

not(filter)
```

## Arguments

- x:

  A single value to compare against. `Date` and `POSIXct` values are
  formatted for the API; logicals become `true` and `false`.

- pattern:

  A pattern for `like()`, `ilike()`, `re_match()` and `re_imatch()`.

- values:

  A vector of values for `in_()`.

- filter:

  A filter built by one of the other operators, to be negated.

## Value

An object of class `tg_filter`.

## Details

A bare value is shorthand for `eq()`, and a bare vector of length
greater than one is shorthand for `in_()`, so `aa_ano_plano_acao = 2024`
and `aa_ano_plano_acao = c(2024, 2025)` both work. Pass a list of
operators to apply several conditions to the same column, which the API
combines with AND:
`dt_inicio_vigencia = list(gte("2024-01-01"), lt("2025-01-01"))`.

In `like()` and `ilike()` the wildcard may be written as `*` or `%`. In
`re_match()` and `re_imatch()` the operand is a POSIX regular
expression.

## See also

Other filters:
[`tg_operators()`](https://strategicprojects.github.io/transferegovr/reference/tg_operators.md)

## Examples

``` r
gte(2024)
#> <tg_filter> gte.2024
in_(c("PE", "PB"))
#> <tg_filter> in.("PE","PB")
not(is_null())
#> <tg_filter> not.is.null

if (interactive()) {
  tg_get("ted", "plano_acao", aa_ano_plano_acao = gte(2024))
}
```
