# Tests that talk to the real services. They are skipped unless
# TRANSFEREGOVR_LIVE_TESTS is set, because CRAN's checks must not depend on the
# government's servers.
#
#   TRANSFEREGOVR_LIVE_TESTS=1 devtools::test()

skip_unless_live <- function() {
  testthat::skip_if_not(
    identical(Sys.getenv("TRANSFEREGOVR_LIVE_TESTS"), "1"),
    "live tests are off"
  )
  testthat::skip_if_offline()
}

test_that("every table in the frozen schema still answers", {
  skip_unless_live()

  tables <- tg_tables()

  failures <- character()

  for (i in seq_len(nrow(tables))) {
    result <- tryCatch(
      tg_get(tables$module[[i]], tables$table[[i]], .limit = 1,
             .progress = FALSE),
      error = function(e) e
    )

    if (inherits(result, "error")) {
      failures <- c(
        failures,
        paste0(tables$module[[i]], "/", tables$table[[i]], ": ",
               conditionMessage(result))
      )
    }
  }

  expect_equal(failures, character())
})

test_that("the frozen columns match what the services send", {
  skip_unless_live()

  tables <- tg_tables()
  drift <- character()

  for (i in seq_len(nrow(tables))) {
    module <- tables$module[[i]]
    table <- tables$table[[i]]

    rows <- tg_get(module, table, .limit = 1, .progress = FALSE)
    if (nrow(rows) == 0L) {
      next
    }

    expected <- tg_fields(module, table)$field
    unexpected <- setdiff(names(rows), expected)
    missing <- setdiff(expected, names(rows))

    if (length(unexpected) > 0L || length(missing) > 0L) {
      drift <- c(drift, paste0(
        module, "/", table,
        ": new ", paste(unexpected, collapse = ","),
        " gone ", paste(missing, collapse = ",")
      ))
    }
  }

  expect_equal(drift, character())
})

# Pagination ------------------------------------------------------------------
#
# A row count proves nothing about pagination. What proves pages neither
# overlap nor skip is fetching the same rows at two page sizes and comparing
# them, which is also what establishes that the server's order is stable.

test_that("the same rows come back whatever the page size", {
  skip_unless_live()

  strip <- function(x) {
    x <- as.data.frame(x)
    attr(x, "transferegovr_metadata") <- NULL
    rownames(x) <- NULL
    x
  }

  big <- tg_get("especiais", "meta_especiais", .limit = 450, .page_size = 200,
                .progress = FALSE)
  small <- tg_get("especiais", "meta_especiais", .limit = 450, .page_size = 50,
                  .progress = FALSE)

  expect_equal(nrow(big), 450L)
  expect_equal(strip(big), strip(small))
  expect_equal(tg_metadata(big)$pages, 3L)
  expect_equal(tg_metadata(small)$pages, 9L)
})

test_that("the order is stable deep into a large table", {
  skip_unless_live()

  first <- tg_get("especiais", "meta_especiais", .limit = 100,
                  .offset = 100000, .page_size = 100, .progress = FALSE)
  again <- tg_get("especiais", "meta_especiais", .limit = 100,
                  .offset = 100000, .page_size = 50, .progress = FALSE,
                  .cache = FALSE)

  expect_equal(first$id_meta, again$id_meta)
})

test_that("an offset lands on the row it names", {
  skip_unless_live()

  full <- tg_get("especiais", "meta_especiais", .limit = 300, .page_size = 200,
                 .progress = FALSE)
  offset <- tg_get("especiais", "meta_especiais", .limit = 100, .offset = 137,
                   .page_size = 60, .progress = FALSE)

  expect_equal(offset$id_meta, full$id_meta[138:237])
})

# Filters ---------------------------------------------------------------------

test_that("a filter narrows the result and the total agrees with it", {
  skip_unless_live()

  total <- tg_count("parcerias", "proposta")
  filtered <- tg_count("parcerias", "proposta", sg_uf_recebedor = "PE")

  expect_lt(filtered, total)
  expect_gt(filtered, 0)

  rows <- tg_get("parcerias", "proposta", sg_uf_recebedor = "PE", .limit = 25,
                 .progress = FALSE)
  expect_true(all(rows$sg_uf_recebedor == "PE"))
  expect_equal(tg_metadata(rows)$total_rows, filtered)
})

test_that("filters combine with AND", {
  skip_unless_live()

  uf <- tg_count("parcerias", "proposta", sg_uf_recebedor = "PE")
  both <- tg_count("parcerias", "proposta", sg_uf_recebedor = "PE",
                   situacao_proposta = "Aprovada")

  expect_lte(both, uf)
})

test_that("the enumerations the schema froze are the ones the service takes", {
  skip_unless_live()

  values <- tg_params("parcerias", "proposta")
  permitted <- values$values[[match("situacao_proposta", values$param)]]

  for (value in permitted) {
    expect_no_error(
      tg_count("parcerias", "proposta", situacao_proposta = value)
    )
  }
})

# The property that motivates validating parameter names client-side ----------

test_that("the service really does ignore an unknown parameter", {
  skip_unless_live()

  # If this ever starts failing because the service began rejecting unknown
  # parameters, the client-side check in `.tg_validate_params()` could be
  # relaxed. Until then it is the only thing standing between a typo and a
  # silently unfiltered answer.
  withr::local_options(transferegovr.validate = FALSE)

  total <- tg_count("parcerias", "proposta")
  bogus <- tg_count("parcerias", "proposta", in_situacao_proposta = "Aprovada")

  expect_equal(bogus, total)
})

# Freshness -------------------------------------------------------------------

test_that("every module reports when it was last loaded", {
  skip_unless_live()

  for (module in tg_modules()$module) {
    stamp <- tg_updated_at(module)
    expect_s3_class(stamp, "POSIXct")
    expect_gt(stamp, as.POSIXct("2020-01-01", tz = "UTC"))
  }
})

# Nested columns --------------------------------------------------------------

test_that("a nested column arrives as a list column matching its sub-schema", {
  skip_unless_live()

  rows <- tg_get("parcerias", "programa", .limit = 20, .progress = FALSE)

  expect_type(rows$ufs_habilitadas, "list")

  populated <- rows$ufs_habilitadas[lengths(rows$ufs_habilitadas) > 0]
  skip_if(length(populated) == 0L, "no nested rows in this sample")

  expect_setequal(
    names(populated[[1]][[1]]),
    tg_fields("parcerias", "programa", nested = "ufs_habilitadas")$field
  )
})
