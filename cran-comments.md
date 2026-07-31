## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Notes on the package

* All examples that would contact the government's APIs are wrapped in
  `if (interactive())`. They are not wrapped in `\donttest{}` because
  `\donttest{}` runs under `--run-donttest`, which would make CRAN's checks
  depend on a public service being reachable.

* Vignettes are built with `eval = FALSE` for the same reason: every code chunk
  that would query the APIs shows its output as a comment instead of running.

* The test suite runs entirely against mocked responses. Live integration tests
  are skipped unless the `TRANSFEREGOVR_LIVE_TESTS` environment variable is set.

* Nothing is written outside the session unless the user asks for it: the
  response cache defaults to `tempdir()`, and `tg_cache_dir()` must be called
  explicitly to make it persistent.

* Table names, column names and categorical values appear in Portuguese in the
  documentation. They are the APIs' own identifiers and cannot be translated
  without breaking the queries they name.
