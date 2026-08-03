## R CMD check results

0 errors | 0 warnings | 0 notes

## About this version

Version 0.1.0 was submitted on 2026-07-31 and covered the TransfereGov
'PostgREST' services at `api.transferegov.gestao.gov.br`.

The platform also publishes a second set of services, at
`api-publica.transferegov.gestao.gov.br`, with a different contract:
page-number pagination, typed query parameters instead of operators, and a
module ('parcerias') that the first host does not serve at all. Version 0.2.0
targets those services instead. It is a rewrite rather than an addition, so it
supersedes the pending 0.1.0 submission.

## Test environments

* macOS 15 (local), R 4.6.0
* GitHub Actions: ubuntu-latest (R-devel, R-release, R-oldrel-1, R 4.1),
  macOS-latest (R-release), windows-latest (R-release)

The R 4.1 job exists because `DESCRIPTION` declares `R (>= 4.1.0)`; the floor is
tested rather than assumed.

## Notes on the package

* All examples that would contact the government's APIs are wrapped in
  `if (interactive())`. They are not wrapped in `\donttest{}` because
  `\donttest{}` runs under `--run-donttest`, which would make CRAN's checks
  depend on a public service being reachable.

* Vignettes are built with `eval = FALSE` for the same reason: every code chunk
  that would query the APIs shows its output as a comment instead of running.
  No vignette makes a network request at build time.

* The test suite runs entirely against mocked responses. Live integration tests
  are skipped unless the `TRANSFEREGOVR_LIVE_TESTS` environment variable is set,
  so `R CMD check` never reaches the network.

* Nothing is written outside the session unless the user asks for it: the
  response cache defaults to `tempdir()`, and `tg_cache_dir()` must be called
  explicitly to make it persistent.

* Table names, column names, query parameter names and categorical values
  appear in Portuguese in the documentation, and a few Portuguese words are in
  `inst/WORDLIST`. They are the APIs' own identifiers and cannot be translated
  without breaking the queries they name.
