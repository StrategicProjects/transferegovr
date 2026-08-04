# Where cached responses are stored

Called with no argument, reports the directory in use. Called with a
path, switches to it for the rest of the session.

## Usage

``` r
tg_cache_dir(path = NULL)

tg_cache_pasta(path = NULL)
```

## Arguments

- path:

  A directory to cache responses in, or `NULL` to report the current
  one. The directory is created if it does not exist.

## Value

The cache directory, invisibly when setting it.

## Details

By default responses are cached in the session's temporary directory, so
they are discarded when R exits. To keep them between sessions, set this
to a persistent path, for example
`tg_cache_dir(tools::R_user_dir("transferegovr", "cache"))`, or set the
`TRANSFEREGOVR_CACHE_DIR` environment variable in your `.Renviron`.

Caching is controlled by the `transferegovr.cache` option (`TRUE` by
default) and entries expire after `transferegovr.cache_ttl` seconds
(3600 by default). The data behind these APIs is refreshed daily.

## See also

Other cache:
[`tg_cache_clear()`](https://strategicprojects.github.io/transferegovr/reference/tg_cache_clear.md)

## Examples

``` r
tg_cache_dir()
#> [1] "/tmp/RtmpNGu5Qn/transferegovr-cache"
```
