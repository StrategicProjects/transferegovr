# Regenerates R/sysdata.rda from the OpenAPI documents the TransfereGov open
# data APIs publish.
#
#   Rscript data-raw/schema.R
#
# The schema is frozen into the package rather than fetched at load time so that
# filter validation, column typing and `tg_fields()` work offline, and so that a
# change upstream shows up as a reviewable diff instead of silently altering how
# results are typed. Re-run this script when the APIs gain endpoints, columns or
# query parameters, and record the change in NEWS.md.
#
# Two things are frozen per endpoint, not one:
#
#   fields  the columns a row carries, and the R type each is coerced to
#   params  the query parameters the endpoint accepts, with their types and
#           enumerated values
#
# Freezing `params` is not a convenience. These services ignore a query
# parameter they do not recognise and answer 200 with the whole table, so
# `situacao_proposta` misspelt as `in_situacao_proposta` silently returns
# 88,666 rows instead of 84,258. Only a client-side check against this list
# turns that into an error.

library(httr2)

base_url <- "https://api-publica.transferegov.gestao.gov.br"
modules <- c("especiais", "fundoafundo", "parcerias")

# Parameters the client owns. They are stripped from the frozen parameter list
# so that a caller cannot set them as if they were filters and desynchronise
# the collection loop from the rows it is counting.
pagination_params <- c("pagina", "tamanho_da_pagina")

# The endpoint every module publishes that is not a table: it answers with a
# single object rather than a paginated envelope.
timestamp_path <- "data-atualizacao"

`%||%` <- function(x, y) if (is.null(x)) y else x

# OpenAPI 3.1 expresses "nullable T" as `anyOf: [T, null]`, which is every
# optional parameter and most columns. Unwrapping it first keeps the type
# mapping below reading as one case per type.
unwrap_null <- function(schema) {
  alternatives <- schema$anyOf
  if (is.null(alternatives)) {
    return(schema)
  }

  kept <- Filter(function(a) !identical(a$type, "null"), alternatives)

  if (length(kept) == 1L) kept[[1L]] else schema
}

# JSON types mapped to the R type each value is coerced to.
#
# `integer` becomes double rather than integer, which is a deliberate loss of
# type fidelity. These documents declare no `format`, so int32 and int64 are
# indistinguishable, and identifiers here genuinely exceed .Machine$integer.max
# (`cd_parceria` reaches 202500037062). Typing them as integer would turn those
# into NA. A column must also not change class between pages because one page
# happened to fit.
json_to_r <- function(schema) {
  type <- schema$type %||% ""
  format <- schema$format %||% ""

  if (!is.null(schema[["$ref"]]) || identical(type, "array")) {
    return("list")
  }

  if (identical(type, "string")) {
    return(switch(format,
      "date" = "Date",
      "date-time" = "POSIXct",
      # Date filters are declared as a plain string carrying an anchored
      # pattern rather than `format: date`.
      if (identical(schema$pattern %||% "", "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")) {
        "Date"
      } else {
        "character"
      }
    ))
  }

  switch(type,
    integer = "double",
    number = "double",
    boolean = "logical",
    "character"
  )
}

# The JSON type as declared, kept for `tg_fields()` so a reader can see what the
# API said rather than only what the package made of it.
json_type <- function(schema) {
  if (!is.null(schema[["$ref"]])) {
    return("object")
  }

  type <- schema$type %||% NA_character_
  format <- schema$format %||% NA_character_

  if (identical(type, "array")) {
    return("array")
  }
  if (!is.na(format)) {
    return(paste0(type, " (", format, ")"))
  }

  type
}

clean <- function(x) {
  if (is.null(x)) {
    return(NA_character_)
  }
  x <- trimws(x)
  if (!nzchar(x)) NA_character_ else x
}

# The schema a `$ref` points at, whether the reference is direct or through an
# array's `items`.
ref_name <- function(schema) {
  direct <- schema[["$ref"]]
  if (!is.null(direct)) {
    return(basename(direct))
  }

  items <- schema$items[["$ref"]]
  if (!is.null(items)) {
    return(basename(items))
  }

  NA_character_
}

fetch_spec <- function(module) {
  message("fetching ", module)
  request(base_url) |>
    req_url_path_append(module, "openapi.json") |>
    req_headers(Accept = "application/json") |>
    req_user_agent("transferegovr schema builder") |>
    req_timeout(120) |>
    req_perform() |>
    resp_body_json(simplifyVector = FALSE)
}

# Columns ---------------------------------------------------------------------

build_fields <- function(properties) {
  # Columns are wrapped in `anyOf: [T, null]` exactly as parameters are, so the
  # type, the nested reference and often the description all sit one level in.
  # Reading the wrapper instead of the alternative types every column as
  # character and loses every list column.
  schemas <- lapply(properties, unwrap_null)

  tibble::tibble(
    field = names(properties),
    r_type = vapply(schemas, json_to_r, character(1), USE.NAMES = FALSE),
    api_type = vapply(schemas, json_type, character(1), USE.NAMES = FALSE),
    nested = vapply(schemas, ref_name, character(1), USE.NAMES = FALSE),
    description = vapply(
      seq_along(properties),
      function(i) {
        clean(properties[[i]]$description %||% schemas[[i]]$description)
      },
      character(1)
    )
  )
}

# Query parameters ------------------------------------------------------------

build_params <- function(parameters) {
  parameters <- Filter(
    function(p) !p$name %in% pagination_params,
    parameters
  )

  if (length(parameters) == 0L) {
    return(tibble::tibble(
      param = character(), r_type = character(), api_type = character(),
      values = list(), pattern = character(), description = character()
    ))
  }

  schemas <- lapply(parameters, function(p) unwrap_null(p$schema))

  tibble::tibble(
    param = vapply(parameters, function(p) p$name, character(1)),
    r_type = vapply(schemas, json_to_r, character(1), USE.NAMES = FALSE),
    api_type = vapply(schemas, json_type, character(1), USE.NAMES = FALSE),
    # A list column: an enumerated parameter carries its permitted values, and
    # the rest carry a zero-length vector rather than NA, so a caller can test
    # `length(values[[i]]) > 0` without a type check.
    values = lapply(schemas, function(s) {
      as.character(unlist(s$enum %||% list(), use.names = FALSE))
    }),
    pattern = vapply(
      schemas,
      function(s) clean(s$pattern),
      character(1),
      USE.NAMES = FALSE
    ),
    description = vapply(
      parameters,
      function(p) clean(p$description %||% p$schema$description),
      character(1),
      USE.NAMES = FALSE
    )
  )
}

# Modules ---------------------------------------------------------------------

# An endpoint path is the table's identity upstream, but `-` is not usable as a
# bare argument name in R and the three modules are not even consistent with
# each other: `especiais` publishes `/planos_acao_especiais` while `fundoafundo`
# publishes `/planos-acao`. The underscore form is the name the package
# exposes; `path` keeps what the URL needs.
table_name <- function(path) {
  gsub("-", "_", sub("^/", "", path), fixed = TRUE)
}

build_module <- function(module) {
  spec <- fetch_spec(module)
  schemas <- spec$components$schemas

  paths <- names(spec$paths)
  paths <- paths[table_name(paths) != table_name(timestamp_path)]

  tables <- lapply(paths, function(path) {
    operation <- spec$paths[[path]]$get

    answer <- operation$responses[["200"]]$content[["application/json"]]
    envelope <- basename(answer$schema[["$ref"]])
    item <- basename(schemas[[envelope]]$properties$data$items[["$ref"]])
    properties <- schemas[[item]]$properties

    fields <- build_fields(properties)
    params <- build_params(operation$parameters %||% list())

    # These documents describe the query parameters but leave every response
    # column undescribed. Nearly every column is also filterable under its own
    # name, so the parameter's description is the column's description from the
    # same document, and carrying it across covers 767 of the 811 columns.
    # The rest are the nested list columns and a handful that cannot be
    # filtered; they stay NA rather than being guessed at.
    described <- match(fields$field, params$param)
    fields$description <- ifelse(
      is.na(described), NA_character_, params$description[described]
    )

    # A column holding an array of objects is returned as a list column. The
    # sub-schema is frozen alongside it so `tg_fields()` can describe what is
    # inside instead of reporting an opaque list.
    nested <- stats::setNames(
      lapply(
        fields$nested[!is.na(fields$nested)],
        function(name) build_fields(schemas[[name]]$properties)
      ),
      fields$field[!is.na(fields$nested)]
    )

    list(
      path = sub("^/", "", path),
      summary = clean(operation$summary),
      description = clean(operation$description),
      fields = fields,
      nested = nested,
      params = params
    )
  })

  names(tables) <- table_name(paths)
  tables <- tables[order(names(tables))]

  list(
    path = module,
    base_url = base_url,
    title = trimws(spec$info$title %||% module),
    timestamp_path = timestamp_path,
    tables = tables
  )
}

.tg_schema <- lapply(modules, build_module)
names(.tg_schema) <- modules

# Human-facing module labels and the aliases `.tg_match_module()` accepts.
.tg_module_labels <- c(
  especiais = "Special transfers",
  fundoafundo = "Fund-to-fund transfers",
  parcerias = "Partnerships"
)

.tg_module_aliases <- c(
  transferenciasespeciais = "especiais",
  transferencias_especiais = "especiais",
  especial = "especiais",
  special = "especiais",
  special_transfers = "especiais",
  fundo_a_fundo = "fundoafundo",
  fundo_afundo = "fundoafundo",
  fund_to_fund = "fundoafundo",
  parceria = "parcerias",
  partnerships = "parcerias"
)

.tg_schema_built_at <- Sys.Date()

# The page size the services cap a request at. Asking for more is a 422 rather
# than a silent truncation, so this bound is enforced client-side only to give
# a better error than the server's.
.tg_max_page_size <- 200L

counts <- vapply(.tg_schema, function(m) length(m$tables), integer(1))
columns <- vapply(
  .tg_schema,
  function(m) sum(vapply(m$tables, function(t) nrow(t$fields), integer(1))),
  integer(1)
)
params <- vapply(
  .tg_schema,
  function(m) sum(vapply(m$tables, function(t) nrow(t$params), integer(1))),
  integer(1)
)

for (module in names(.tg_schema)) {
  message(
    "  ", module, ": ", counts[[module]], " tables, ",
    columns[[module]], " columns, ", params[[module]], " parameters"
  )
}
message(
  "total: ", sum(counts), " tables, ", sum(columns), " columns, ",
  sum(params), " parameters"
)

stopifnot(
  length(.tg_schema) == 3L,
  sum(counts) == 55L,
  all(vapply(
    .tg_schema,
    function(m) {
      all(vapply(m$tables, function(t) nrow(t$fields) > 0L, logical(1)))
    },
    logical(1)
  ))
)

save(
  .tg_schema,
  .tg_module_labels,
  .tg_module_aliases,
  .tg_schema_built_at,
  .tg_max_page_size,
  file = "R/sysdata.rda",
  version = 3,
  compress = "xz"
)
