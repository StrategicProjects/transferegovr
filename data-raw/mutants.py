#!/usr/bin/env python3
"""Mutation testing for the transferegovr core.

    python3 data-raw/mutants.py


Each mutant is a deliberate defect. A mutant is KILLED if the test suite fails
with it applied, and SURVIVES if the suite still passes -- which means no test
covers that behaviour.

The edit is verified to have landed before the suite runs. On the 0.1.0 run two
mutants "survived" only because the mutation never applied, which reads as a
suite gap when it is a broken mutator.
"""

import os, re, shutil, subprocess, sys, tempfile

SRC = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (name, file, old, new)
MUTANTS = [
    # --- pagination: R/get.R ---
    ("page-off-by-one", "R/get.R",
     "first_page <- floor(offset / page_size) + 1",
     "first_page <- floor(offset / page_size)"),
    ("offset-remainder-ignored", "R/get.R",
     "drop <- offset %% page_size",
     "drop <- 0"),
    ("skips-every-other-page", "R/get.R",
     "page_number <- page_number + 1",
     "page_number <- page_number + 2"),
    ("collect-one-row-too-many", "R/get.R",
     "while (length(rows) < wanted) {",
     "while (length(rows) <= wanted) {"),
    ("no-final-trim", "R/get.R",
     "  rows <- utils::head(rows, if (is.finite(wanted)) wanted else length(rows))\n\n  .tg_collected(rows, total, pages, offset, page_size, cached, wanted)",
     "  .tg_collected(rows, total, pages, offset, page_size, cached, wanted)"),
    ("limit-ignores-total", "R/get.R",
     "  min(limit, max(0, total - offset))",
     "  limit"),
    ("offset-not-subtracted", "R/get.R",
     "min(limit, max(0, total - offset))",
     "min(limit, max(0, total))"),
    ("short-read-never-warns", "R/get.R",
     "if (is.finite(wanted) && length(rows) != wanted) {",
     "if (FALSE) {"),
    ("always-requests-page-one", "R/get.R",
     "    pagina = format(page, scientific = FALSE),",
     "    pagina = \"1\","),
    ("page-size-cap-lifted", "R/get.R",
     ".tg_check_count(.page_size, \".page_size\", maximum = .tg_max_page_size)",
     ".tg_check_count(.page_size, \".page_size\", maximum = 100000L)"),
    ("count-reads-wrong-field", "R/get.R",
     "  page$total\n}",
     "  page$page_size\n}"),

    # --- filters: R/params.R ---
    ("unknown-param-allowed", "R/params.R",
     "  unknown <- setdiff(unique(names), params$param)",
     "  unknown <- character()"),
    ("multi-value-silently-truncated", "R/params.R",
     "  if (length(value) > 1L) {",
     "  if (FALSE) {"),
    ("duplicate-param-allowed", "R/params.R",
     "  if (length(duplicated) > 0L) {",
     "  if (FALSE) {"),
    ("enum-not-checked", "R/params.R",
     "  if (length(permitted) == 0L || encoded %in% permitted) {",
     "  if (TRUE) {"),
    ("numbers-in-scientific-notation", "R/params.R",
     "    return(format(x, scientific = FALSE, trim = TRUE, digits = 15))",
     "    return(format(x))"),
    ("dates-in-wrong-format", "R/params.R",
     "    return(format(x, \"%Y-%m-%d\"))",
     "    return(format(x, \"%d/%m/%Y\"))"),
    ("logicals-uppercase", "R/params.R",
     "    return(if (x) \"true\" else \"false\")",
     "    return(if (x) \"TRUE\" else \"FALSE\")"),
    ("na-filter-allowed", "R/params.R",
     "  if (is.na(value)) {",
     "  if (FALSE) {"),

    # --- parsing: R/parse.R ---
    ("list-column-flattened", "R/parse.R",
     "  if (identical(type, \"list\")) {",
     "  if (FALSE) {"),
    ("types-inferred-not-declared", "R/parse.R",
     "  if (is.na(index)) NA_character_ else fields$r_type[[index]]",
     "  NA_character_"),
    ("integer-overflow-unchecked", "R/parse.R",
     "  if (any(overflow)) {",
     "  if (FALSE) {"),
    ("empty-result-loses-columns", "R/parse.R",
     "  names <- .tg_row_names(rows) %||% fields$field",
     "  names <- .tg_row_names(rows) %||% character()"),

    # --- transport: R/client.R ---
    ("envelope-not-validated", "R/client.R",
     "  missing <- setdiff(.tg_envelope_fields, names(body))",
     "  missing <- character()"),
    ("422-retried", "R/client.R",
     "  httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L)",
     "  httr2::resp_status(resp) %in% c(422L, 429L, 500L, 502L, 503L, 504L)"),
    ("http-errors-ignored", "R/client.R",
     "  if (status < 400L) {",
     "  if (TRUE) {"),
    ("url-length-unchecked", "R/client.R",
     "  if (length <= .tg_max_url) {",
     "  if (TRUE) {"),

    # --- schema lookup: R/metadata.R ---
    ("table-path-ignored", "R/get.R",
     "  path <- paste0(module, \"/\", .tg_schema[[module]]$tables[[table]]$path)",
     "  path <- paste0(module, \"/\", table)"),
    ("unknown-table-accepted", "R/metadata.R",
     "  if (!key %in% tables) {",
     "  if (FALSE) {"),
]


def run(mutant):
    name, rel, old, new = mutant
    work = tempfile.mkdtemp(prefix="mut-")
    pkg = os.path.join(work, "transferegovr")
    shutil.copytree(SRC, pkg, ignore=shutil.ignore_patterns(
        ".git", ".Rproj.user", "docs", "*.Rcheck", "revdep"))

    path = os.path.join(pkg, rel)
    text = open(path).read()

    occurrences = text.count(old)
    if occurrences != 1:
        shutil.rmtree(work, ignore_errors=True)
        return name, "BROKEN", f"anchor found {occurrences}x, expected 1"

    mutated = text.replace(old, new)
    if mutated == text:
        shutil.rmtree(work, ignore_errors=True)
        return name, "BROKEN", "replacement changed nothing"
    open(path, "w").write(mutated)

    # Re-read and confirm the edit is on disk, not just in memory.
    if open(path).read() != mutated:
        shutil.rmtree(work, ignore_errors=True)
        return name, "BROKEN", "edit did not land on disk"

    proc = subprocess.run(
        ["Rscript", "-e",
         'r <- testthat::test_local(".", reporter = "silent", stop_on_failure = FALSE);'
         'df <- as.data.frame(r);'
         'cat("FAILED:", sum(df$failed) + sum(df$error), "\\n")'],
        cwd=pkg, capture_output=True, text=True, timeout=900)

    out = proc.stdout + proc.stderr
    m = re.search(r"FAILED:\s*(\d+)", out)
    shutil.rmtree(work, ignore_errors=True)

    if proc.returncode != 0 and m is None:
        # The package would not even load or the run crashed: still a kill,
        # but worth distinguishing from a clean test failure.
        return name, "KILLED", "suite could not run"
    if m is None:
        return name, "BROKEN", "no result parsed"

    failed = int(m.group(1))
    return name, ("KILLED" if failed > 0 else "SURVIVED"), f"{failed} failing"


def main():
    killed = survived = broken = 0
    for mutant in MUTANTS:
        name, verdict, detail = run(mutant)
        print(f"{verdict:9s} {name:34s} {detail}", flush=True)
        if verdict == "KILLED":
            killed += 1
        elif verdict == "SURVIVED":
            survived += 1
        else:
            broken += 1

    total = len(MUTANTS)
    print(f"\nkilled {killed}/{total}, survived {survived}, broken {broken}")
    sys.exit(1 if survived or broken else 0)


if __name__ == "__main__":
    main()
