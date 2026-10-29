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
modules <- c(
  "discricionarias", "especiais", "fundoafundo", "parcerias", "ted"
)

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

# Multi-valued parameters -----------------------------------------------------

# Some parameters take a comma-separated list and match any of its values -- an
# "is one of" -- and the rest take a single value. The OpenAPI documents do not
# say which: both are declared as a plain string. Nor does the name: 141
# parameters take a list, several of them not named `id_*`, while several
# `id_*` strings do not. So it is asked of the service, which is how every
# other behaviour frozen here was established.
#
# A list-taking parameter rejects a non-integer with a 400 whose message says
# it wants "números inteiros separados por vírgula"; any other parameter treats
# "x" as an ordinary value, and a parameter typed integer or number is
# validated by FastAPI itself (422), so it is never a candidate. Sent more
# values than it allows, a list parameter answers with the limit -- 100 in
# `especiais`, 200 elsewhere, so that is read per parameter too.
#
# `discricionarias` complicates both halves. Its `/propostas` and
# `/propostas-canceladas` crash on a non-integer -- a bare 500 "Erro Interno
# Inesperado" -- instead of answering the 400, and past the value limit they
# answer the same 500 with no limit in it. So there a 500 is confirmed as
# "takes a list" by sending one, and the limit is read from the status by
# bisection. Over a thousand requests in all, a few minutes.
list_marker <- "separados por v"
limit_pattern <- "m\u00e1ximo de valores poss\u00edveis.* \u00e9 ([0-9]+)"

probe <- function(module, path, query) {
  request(base_url) |>
    req_url_path_append(module, path) |>
    req_url_query(!!!c(list(tamanho_da_pagina = 1), query)) |>
    req_user_agent("transferegovr schema builder") |>
    req_throttle(capacity = 300, fill_time_s = 60) |>
    req_retry(max_tries = 4, is_transient = function(r) {
      resp_status(r) %in% c(429L, 502L, 503L, 504L)
    }) |>
    req_error(is_error = function(r) FALSE) |>
    req_timeout(120) |>
    req_perform()
}

probe_lists <- function(module, path, params) {
  params$multiple <- rep(FALSE, nrow(params))
  params$max_values <- rep(1L, nrow(params))

  candidates <- which(
    params$api_type == "string" &
      lengths(params$values) == 0L &
      is.na(params$pattern)
  )

  for (i in candidates) {
    name <- params$param[[i]]
    response <- probe(module, path, stats::setNames(list("x"), name))
    status <- resp_status(response)

    takes_list <- status == 400L &&
      grepl(list_marker, resp_body_string(response))

    if (!takes_list && status == 500L) {
      # A 500 alone does not say "list": it says the endpoint crashed instead
      # of validating. Only a two-value list coming back 200 does. When even
      # that fails, a single value tells the rest apart: accepted, this is an
      # ordinary one-value parameter that crashes on a non-number instead of
      # rejecting it; refused as well, the filter is broken upstream for every
      # value, and it is frozen as single-valued so the client at least names
      # the parameter when the 500 comes back.
      confirmation <- probe(module, path, stats::setNames(list("1,2"), name))
      if (resp_status(confirmation) == 200L) {
        takes_list <- TRUE
      } else {
        single <- probe(module, path, stats::setNames(list("1"), name))
        if (resp_status(single) != 200L) {
          message("  ", module, "/", path, " ", name,
                  ": a 500 for every value probed")
        }
      }
    }

    if (!takes_list) {
      next
    }

    params$multiple[[i]] <- TRUE
    params$max_values[[i]] <- probe_limit(module, path, name)
  }

  params
}

# How many values one list parameter accepts. Most endpoints name the limit in
# a 400; the ones that answer a bare 500 get it read from the status instead,
# with the limit every other parameter has reported tried first so that the
# bisection only runs when an endpoint deviates.
probe_limit <- function(module, path, name) {
  accepts <- function(n) {
    values <- paste(seq_len(n), collapse = ",")
    response <- probe(module, path, stats::setNames(list(values), name))
    status <- resp_status(response)

    if (status == 200L) {
      return(TRUE)
    }
    limit <- regmatches(
      resp_body_string(response),
      regexec(limit_pattern, resp_body_string(response))
    )[[1]]
    if (length(limit) == 2L) {
      return(as.integer(limit[[2]]))
    }
    FALSE
  }

  first <- accepts(1001L)
  if (is.integer(first)) {
    return(first)
  }
  if (isTRUE(first)) {
    stop(module, "/", path, " ", name,
         " accepted 1001 values; it has no limit to freeze", call. = FALSE)
  }

  if (isTRUE(accepts(200L)) && isFALSE(accepts(201L))) {
    return(200L)
  }

  lower <- 1L # a single value always works
  upper <- 1001L # just shown to fail
  while (upper - lower > 1L) {
    middle <- as.integer((lower + upper) %/% 2L)
    outcome <- accepts(middle)
    if (is.integer(outcome)) {
      return(outcome)
    }
    if (isTRUE(outcome)) lower <- middle else upper <- middle
  }
  lower
}

# Modules ---------------------------------------------------------------------

# An endpoint path is the table's identity upstream, but `-` is not usable as a
# bare argument name in R, and the spelling is not stable: `especiais` published
# `/planos_acao_especiais` until September 2026 and `/planos-acao-especiais`
# after it, with every older spelling answering 404. The underscore form is the
# name the package exposes, so that change never reaches a caller's code;
# `path` keeps what the URL needs.
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
    params <- probe_lists(
      module, sub("^/", "", path),
      build_params(operation$parameters %||% list())
    )

    # These documents describe the query parameters but leave every response
    # column undescribed. Nearly every column is also filterable under its own
    # name, so the parameter's description is the column's description from the
    # same document, and carrying it across covers 1,241 of the 1,300 columns.
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
    max_page_size = max_page_size(spec, paths, module),
    tables = tables
  )
}

# The largest page a module serves. It is not the same everywhere: `especiais`
# and `parcerias` declare 200, `fundoafundo` and `ted` 1000, and each service
# answers 422 one row above its own limit. Read from the document rather than
# assumed, and required to agree across a module's endpoints, since the client
# applies it per module.
max_page_size <- function(spec, paths, module) {
  maxima <- vapply(paths, function(path) {
    parameters <- spec$paths[[path]]$get$parameters %||% list()
    size <- Filter(
      function(p) identical(p$name, "tamanho_da_pagina"),
      parameters
    )
    if (length(size) != 1L) {
      stop(module, path, " declares no tamanho_da_pagina", call. = FALSE)
    }
    as.integer(unwrap_null(size[[1L]]$schema)$maximum %||% NA_integer_)
  }, integer(1))

  if (anyNA(maxima) || length(unique(maxima)) != 1L) {
    stop(module, " declares inconsistent page size limits: ",
         paste(unique(maxima), collapse = ", "), call. = FALSE)
  }

  maxima[[1L]]
}

.tg_schema <- lapply(modules, build_module)
names(.tg_schema) <- modules

# Human-facing module labels and the aliases `.tg_match_module()` accepts.
.tg_module_labels <- c(
  discricionarias = "Discretionary and legal transfers",
  especiais = "Special transfers",
  fundoafundo = "Fund-to-fund transfers",
  parcerias = "Partnerships",
  ted = "Decentralized credit"
)

.tg_module_aliases <- c(
  discricionarias_e_legais = "discricionarias",
  transferencias_discricionarias = "discricionarias",
  discretionary = "discricionarias",
  discretionary_and_legal = "discricionarias",
  # The system these transfers lived in before Transferegov absorbed it; its
  # CSV dumps are published under this name to this day.
  siconv = "discricionarias",
  transferenciasespeciais = "especiais",
  transferencias_especiais = "especiais",
  especial = "especiais",
  special = "especiais",
  special_transfers = "especiais",
  fundo_a_fundo = "fundoafundo",
  fundo_afundo = "fundoafundo",
  fund_to_fund = "fundoafundo",
  parceria = "parcerias",
  partnerships = "parcerias",
  termo_de_execucao_descentralizada = "ted",
  termo_execucao_descentralizada = "ted",
  decentralized_credit = "ted"
)

.tg_schema_built_at <- Sys.Date()

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
    columns[[module]], " columns, ", params[[module]], " parameters, ",
    "pages of up to ", .tg_schema[[module]]$max_page_size
  )
}
message(
  "total: ", sum(counts), " tables, ", sum(columns), " columns, ",
  sum(params), " parameters"
)
lists <- vapply(
  .tg_schema,
  function(m) sum(vapply(m$tables, function(t) sum(t$params$multiple), 1)),
  numeric(1)
)
message("parameters taking a list: ", sum(lists), " (",
        paste(names(lists), lists, sep = " ", collapse = ", "), ")")

stopifnot(
  length(.tg_schema) == 5L,
  sum(counts) == 86L,
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
  file = "R/sysdata.rda",
  version = 3,
  compress = "xz"
)
