# Contributing to transferegovr

## Reporting a problem

Open an issue with a reproducible example. If it involves a specific query,
include the module, the table, and the filters, so the request can be repeated.

## Making a change

1. Fork the repository and create a branch.
2. Make the change, with a test that fails without it. A test that passes
   against both the old and the new code proves nothing; check it by stashing
   the change (`git stash push R/`) and running the test again.
3. Run, in this order:

   ```r
   roxygen2::roxygenise()
   devtools::test()
   lintr::lint_package()
   devtools::check()
   ```

   `lintr` must report nothing against the project `.lintr`.
4. Add an entry to `NEWS.md` and open a pull request.

## Updating the frozen schema

The package validates filters and types columns from a copy of the APIs' OpenAPI
documents in `R/sysdata.rda`. When the APIs publish new tables or columns:

```sh
Rscript data-raw/schema.R
```

Commit the resulting `R/sysdata.rda` and note the change in `NEWS.md`. The live
tests (`TRANSFEREGOVR_LIVE_TESTS=1 devtools::test()`) check the frozen schema
against what the APIs actually return.

## Conduct

Contributors must follow the [Code of Conduct](CODE_OF_CONDUCT.md).
