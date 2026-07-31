## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.

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

* Table names, column names and categorical values appear in Portuguese in the
  documentation, and a few Portuguese words are in `inst/WORDLIST`. They are the
  APIs' own identifiers and cannot be translated without breaking the queries
  they name.
