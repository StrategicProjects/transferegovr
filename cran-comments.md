## R CMD check results

0 errors | 0 warnings | 1 note

* `checking HTML version of manual ... NOTE / Skipping checking HTML
  validation: 'tidy' doesn't look like recent enough HTML Tidy` — the HTML Tidy
  shipped with macOS is older than the check wants. This is a property of the
  submitting machine, not of the package.

## Reverse dependencies

There are none.

## About this version

Version 0.1.0, published on 2026-08-08, covers the TransfereGov 'PostgREST'
services at `api.transferegov.gestao.gov.br`. The government has announced
the retirement of those services, and publishes their replacement at
`api-publica.transferegov.gestao.gov.br`: a different contract, with
page-number pagination, typed query parameters instead of operators, and a
module ('parcerias') that the first host does not serve at all.

Version 0.2.0 moves the package to the replacement services. It is a rewrite
rather than an addition, and it breaks code written against 0.1.0; `NEWS.md`
lists every change. It follows 0.1.0 more closely than usual because the
services 0.1.0 depends on are being withdrawn.

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
