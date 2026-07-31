# Regenerates R/sysdata.rda from the OpenAPI documents the three TransfereGov
# APIs publish at their roots.
#
#   Rscript data-raw/schema.R
#
# The schema is frozen into the package rather than fetched at load time so that
# filter validation, column typing and `tg_fields()` work offline, and so that a
# change upstream shows up as a reviewable diff instead of silently altering how
# results are typed. Re-run this script when the APIs publish new tables or
# columns, and record the change in NEWS.md.

library(httr2)

base_url <- "https://api.transferegov.gestao.gov.br"
modules <- c("transferenciasespeciais", "fundoafundo", "ted")

# Postgres types, as reported in the OpenAPI `format` field, mapped to the R
# type each column is coerced to. `bigint` becomes double rather than integer:
# a value beyond .Machine$integer.max would otherwise become NA, and a column
# must not change class between pages because one page happened to fit.
pg_to_r <- function(format, type) {
  by_format <- c(
    "date" = "Date",
    "timestamp without time zone" = "POSIXct",
    "timestamp with time zone" = "POSIXct",
    "boolean" = "logical",
    "smallint" = "integer",
    "integer" = "integer",
    "bigint" = "double",
    "numeric" = "double",
    "double precision" = "double",
    "real" = "double",
    "character varying" = "character",
    "character" = "character",
    "text" = "character"
  )

  mapped <- unname(by_format[format])

  if (!is.na(mapped)) {
    return(mapped)
  }

  switch(type,
    integer = "integer",
    number = "double",
    boolean = "logical",
    "character"
  )
}

# PostgREST appends a primary-key marker to the column description.
pk_marker <- "This is a Primary Key"

clean_description <- function(x) {
  if (is.null(x)) {
    return(NA_character_)
  }
  x <- sub("\\s*Note:\\s*This is a (Primary|Foreign) Key.*$", "", x)
  x <- trimws(x)
  if (!nzchar(x)) NA_character_ else x
}

fetch_spec <- function(module) {
  message("fetching ", module)
  request(base_url) |>
    req_url_path_append(module, "") |>
    req_headers(Accept = "application/openapi+json") |>
    req_user_agent("transferegovr schema builder") |>
    req_timeout(120) |>
    req_perform() |>
    resp_body_json(simplifyVector = FALSE)
}

build_module <- function(module) {
  spec <- fetch_spec(module)

  tables <- lapply(names(spec$definitions), function(table) {
    properties <- spec$definitions[[table]]$properties

    fields <- tibble::tibble(
      field = names(properties),
      r_type = vapply(
        properties,
        function(p) pg_to_r(p$format %||% "", p$type %||% ""),
        character(1),
        USE.NAMES = FALSE
      ),
      pg_type = vapply(
        properties,
        function(p) p$format %||% NA_character_,
        character(1),
        USE.NAMES = FALSE
      ),
      primary_key = vapply(
        properties,
        function(p) grepl(pk_marker, p$description %||% "", fixed = TRUE),
        logical(1),
        USE.NAMES = FALSE
      ),
      description = vapply(
        properties,
        function(p) clean_description(p$description),
        character(1),
        USE.NAMES = FALSE
      )
    )

    list(
      description = clean_description(spec$definitions[[table]]$description),
      fields = fields
    )
  })

  names(tables) <- names(spec$definitions)
  tables <- tables[order(names(tables))]

  list(
    path = module,
    title = trimws(spec$info$title %||% module),
    description = trimws(spec$info$description %||% ""),
    tables = tables
  )
}

`%||%` <- function(x, y) if (is.null(x)) y else x

.tg_schema <- lapply(modules, build_module)
names(.tg_schema) <- modules

# Human-facing module labels and the aliases `.tg_match_module()` accepts.
.tg_module_labels <- c(
  transferenciasespeciais = "Special transfers",
  fundoafundo = "Fund-to-fund transfers",
  ted = "Decentralised credit (TED)"
)

.tg_module_aliases <- c(
  transferencias_especiais = "transferenciasespeciais",
  especiais = "transferenciasespeciais",
  special = "transferenciasespeciais",
  special_transfers = "transferenciasespeciais",
  fundo_a_fundo = "fundoafundo",
  fundo_afundo = "fundoafundo",
  fund_to_fund = "fundoafundo",
  ted = "ted",
  decentralised_credit = "ted",
  decentralized_credit = "ted"
)

.tg_schema_built_at <- Sys.Date()

stopifnot(
  length(.tg_schema) == 3L,
  sum(vapply(.tg_schema, function(m) length(m$tables), integer(1))) == 48L
)

message(
  "tables: ",
  sum(vapply(.tg_schema, function(m) length(m$tables), integer(1))),
  " | columns: ",
  sum(vapply(
    .tg_schema,
    function(m) sum(vapply(m$tables, function(t) nrow(t$fields), integer(1))),
    integer(1)
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
