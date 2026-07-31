# Generates man/figures/logo.svg.
#
#   Rscript data-raw/logo.R
#
# The wordmark is emitted as outlines rather than <text>, so the logo renders
# identically whether or not Montserrat (SIL Open Font License) is installed on
# the viewer's machine. That also means the file cannot be edited as text: to
# change the wordmark, edit `wordmark_text` here and re-run.

library(systemfonts)

family_name <- "Montserrat"
wordmark_text <- "transferegovr"
weight <- 700
upem <- 1000 # glyphs are extracted at this size, so coordinates are font units

# Navy field and blueprint grid keep the family resemblance with obrasgovr; the
# green accent is what distinguishes this package from it.
field <- "#0A2540"
grid <- "#2E6FD9"
ink <- "#FFFFFF"
accent <- "#3FD98A"
edge <- "#05172A"

svg_w <- 600
svg_h <- 692.82 # 600 * 2 / sqrt(3), the standard hex sticker ratio

# Half the hexagon's width at a given height. The wordmark has to fit inside
# this, not inside `svg_w`: at the baseline the hexagon is far narrower than the
# viewBox, which is what pushes a full-width wordmark out past the border.
hex_half_width <- function(y) {
  if (y <= svg_h / 4) {
    return(svg_w / 2 * (y / (svg_h / 4)))
  }
  if (y >= 3 * svg_h / 4) {
    return(svg_w / 2 * ((svg_h - y) / (svg_h / 4)))
  }
  svg_w / 2
}

hex_path <- function(inset = 0) {
  cx <- svg_w / 2
  cy <- svg_h / 2
  rx <- svg_w / 2 - inset
  ry <- svg_h / 2 - inset * (svg_h / svg_w)

  points <- list(
    c(cx, cy - ry), c(cx + rx, cy - ry / 2), c(cx + rx, cy + ry / 2),
    c(cx, cy + ry), c(cx - rx, cy + ry / 2), c(cx - rx, cy - ry / 2)
  )

  paste0(
    "M",
    paste(vapply(
      points, function(p) sprintf("%.2f %.2f", p[[1]], p[[2]]),
      character(1)
    ), collapse = "L"),
    "Z"
  )
}

# Wordmark -------------------------------------------------------------------

# Montserrat is only installed here as a variable font. `shape_text()` has no
# way to set a variation axis, so its advances come from the font's default
# instance, which is much lighter and narrower than the weight being drawn --
# laying the glyphs out with them would overlap every letter. Advances and
# outlines are therefore both taken from `glyph_info()`/`glyph_outline()` with
# the same explicit `wght`.
glyph_paths <- function(text, weight) {
  font <- match_fonts(family_name)
  variation <- font_variation(weight = weight)

  info <- glyph_info(
    glyphs = text,
    path = font$path,
    index = font$index,
    size = upem,
    variation = list(variation)
  )

  n <- nrow(info)

  outlines <- glyph_outline(
    glyph = info$index,
    path = rep(font$path, n),
    index = rep(font$index, n),
    size = upem,
    tolerance = 0.4,
    variation = rep(list(variation), n)
  )

  paths <- vapply(seq_len(n), function(i) {
    points <- outlines[outlines$glyph == i, ]

    if (nrow(points) == 0L) {
      return("")
    }

    paste0(
      vapply(split(points, points$contour), function(contour) {
        # y is negated: font coordinates grow upwards, SVG downwards.
        paste0(
          "M",
          paste(sprintf("%d %d", round(contour$x), round(-contour$y)),
            collapse = "L"
          ),
          "Z"
        )
      }, character(1)),
      collapse = ""
    )
  }, character(1))

  list(
    paths = paths,
    offsets = cumsum(c(0, info$x_advance[-n])),
    width = sum(info$x_advance)
  )
}

# Icon ------------------------------------------------------------------------

# One source distributing to three: the Union transferring to states, the
# Federal District and municipalities, and equally the three modalities this
# package covers. A bus with square elbows rather than curves -- over this
# span the curves read as slack rope rather than as flow.
source_box <- list(x = 254, y = 158, size = 92, radius = 18)
bus_y <- 318
drop_end <- 360
arrow_tip <- 382
target_y <- 418
target_r <- 34
target_x <- c(152, 300, 448)

arrowhead <- function(x) {
  sprintf(
    "M%.0f %.0fL%.0f %.0fL%.0f %.0fZ",
    x - 16, drop_end, x + 16, drop_end, x, arrow_tip
  )
}

# Assembly --------------------------------------------------------------------

wordmark <- glyph_paths(wordmark_text, weight)

baseline <- 538
descender <- 0.22 # of the em, enough for the "g"
wordmark_width <- 420
scale <- wordmark_width / wordmark$width
left <- (svg_w - wordmark_width) / 2

# The wordmark must clear the inner border at its lowest point, not just at the
# baseline.
lowest <- baseline + wordmark_width / wordmark$width * upem * descender
stopifnot(wordmark_width / 2 <= hex_half_width(lowest) - 30)

glyph_svg <- vapply(seq_along(wordmark$paths), function(i) {
  # The trailing "r" is the accent, as in obrasgovr: it is the R in the name.
  fill <- if (i == length(wordmark$paths)) accent else ink

  sprintf(
    '    <path fill="%s" transform="translate(%.0f 0)" d="%s"/>',
    fill, wordmark$offsets[[i]], wordmark$paths[[i]]
  )
}, character(1))

grid_lines <- paste0(
  paste0(sprintf("M0 %dH%d", seq(48, 672, by = 48), svg_w), collapse = ""),
  paste0(
    sprintf("M%d 0V%d", seq(48, 552, by = 48), ceiling(svg_h)),
    collapse = ""
  )
)

svg <- c(
  '<?xml version="1.0" encoding="UTF-8"?>',
  sprintf(
    paste0(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %.2f" ',
      'width="%d" height="%.2f" role="img" ',
      'aria-labelledby="logo-title logo-desc">'
    ),
    svg_w, svg_h, svg_w, svg_h
  ),
  "  <title id=\"logo-title\">transferegovr</title>",
  paste0(
    '  <desc id="logo-desc">Hexagonal logo: a single source distributing to ',
    "three recipients on a navy blueprint field, above the transferegovr ",
    "wordmark.</desc>"
  ),
  "  <defs>",
  sprintf(
    '    <clipPath id="transferegovr-hex"><path d="%s"/></clipPath>',
    hex_path(0)
  ),
  "  </defs>",
  "",
  sprintf('  <path d="%s" fill="%s"/>', hex_path(0), field),
  "",
  "  <!-- blueprint grid -->",
  sprintf(
    paste0(
      '  <g clip-path="url(#transferegovr-hex)" fill="none" stroke="%s" ',
      'stroke-width="1.5" opacity="0.12">'
    ),
    grid
  ),
  sprintf('    <path d="%s"/>', grid_lines),
  "  </g>",
  "",
  "  <!-- one source, three transfers -->",
  sprintf(
    paste0(
      '  <g fill="none" stroke="%s" stroke-width="14" stroke-linecap="round" ',
      'stroke-linejoin="round">'
    ),
    ink
  ),
  sprintf(
    '    <path d="M300 %d V%d"/>', source_box$y + source_box$size, bus_y
  ),
  sprintf(
    '    <path d="M%d %d V%d H%d V%d"/>',
    target_x[[1]], drop_end, bus_y, target_x[[3]], drop_end
  ),
  sprintf('    <path d="M300 %d V%d"/>', bus_y, drop_end),
  "  </g>",
  sprintf('  <g fill="%s">', ink),
  sprintf(
    '    <rect x="%d" y="%d" width="%d" height="%d" rx="%d"/>',
    source_box$x, source_box$y, source_box$size, source_box$size,
    source_box$radius
  ),
  paste0(sprintf(
    '    <path d="%s"/>', vapply(target_x, arrowhead, character(1))
  )),
  "  </g>",
  sprintf('  <g fill="%s">', accent),
  paste0(sprintf(
    '    <circle cx="%d" cy="%d" r="%d"/>', target_x, target_y, target_r
  )),
  "  </g>",
  "",
  "  <!-- wordmark, outlined so no font is required -->",
  sprintf(
    '  <g transform="translate(%.2f %d) scale(%.5f)">', left, baseline, scale
  ),
  glyph_svg,
  "  </g>",
  "",
  "  <!-- borders -->",
  sprintf(
    '  <path d="%s" fill="none" stroke="%s" stroke-width="12"/>',
    hex_path(6), edge
  ),
  sprintf(
    '  <path d="%s" fill="none" stroke="%s" stroke-width="4"/>',
    hex_path(18), accent
  ),
  "</svg>",
  ""
)

dir.create("man/figures", recursive = TRUE, showWarnings = FALSE)
writeLines(svg, "man/figures/logo.svg")

message(
  "wrote man/figures/logo.svg (",
  round(file.size("man/figures/logo.svg") / 1024, 1), " KB), wordmark ",
  round(wordmark_width), "px wide at wght ", weight
)

# Favicons --------------------------------------------------------------------

# At 32 pixels the wordmark is a smudge, so the mark alone is used, enlarged to
# fill the hexagon. The grid and the inner border go too: both disappear into
# noise at that size.
icon_bounds <- list(
  top = source_box$y,
  bottom = target_y + target_r,
  left = min(target_x) - target_r,
  right = max(target_x) + target_r
)
icon_centre <- c(
  (icon_bounds$left + icon_bounds$right) / 2,
  (icon_bounds$top + icon_bounds$bottom) / 2
)
icon_zoom <- 1.34

favicon <- c(
  '<?xml version="1.0" encoding="UTF-8"?>',
  sprintf(
    paste0(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %.2f" ',
      'role="img" aria-label="transferegovr">'
    ),
    svg_w, svg_h
  ),
  sprintf('  <path d="%s" fill="%s"/>', hex_path(0), field),
  sprintf(
    '  <g transform="translate(%.2f %.2f) scale(%.3f) translate(%.2f %.2f)">',
    svg_w / 2, svg_h / 2, icon_zoom, -icon_centre[[1]], -icon_centre[[2]]
  ),
  sprintf(
    paste0(
      '    <g fill="none" stroke="%s" stroke-width="14" ',
      'stroke-linecap="round" ',
      'stroke-linejoin="round">'
    ),
    ink
  ),
  sprintf(
    '      <path d="M300 %d V%d"/>', source_box$y + source_box$size, bus_y
  ),
  sprintf(
    '      <path d="M%d %d V%d H%d V%d"/>',
    target_x[[1]], drop_end, bus_y, target_x[[3]], drop_end
  ),
  sprintf('      <path d="M300 %d V%d"/>', bus_y, drop_end),
  "    </g>",
  sprintf('    <g fill="%s">', ink),
  sprintf(
    '      <rect x="%d" y="%d" width="%d" height="%d" rx="%d"/>',
    source_box$x, source_box$y, source_box$size, source_box$size,
    source_box$radius
  ),
  paste0(sprintf(
    '      <path d="%s"/>', vapply(target_x, arrowhead, character(1))
  )),
  "    </g>",
  sprintf('    <g fill="%s">', accent),
  paste0(sprintf(
    '      <circle cx="%d" cy="%d" r="%d"/>', target_x, target_y, target_r
  )),
  "    </g>",
  "  </g>",
  sprintf(
    '  <path d="%s" fill="none" stroke="%s" stroke-width="14"/>',
    hex_path(7), edge
  ),
  "</svg>",
  ""
)

dir.create("pkgdown/favicon", recursive = TRUE, showWarnings = FALSE)
writeLines(favicon, "pkgdown/favicon/favicon.svg")

manifest <- c(
  "{",
  '  "name": "transferegovr",',
  '  "short_name": "transferegovr",',
  '  "icons": [',
  "    {",
  '      "src": "web-app-manifest-192x192.png",',
  '      "sizes": "192x192",',
  '      "type": "image/png",',
  '      "purpose": "any"',
  "    },",
  "    {",
  '      "src": "web-app-manifest-512x512.png",',
  '      "sizes": "512x512",',
  '      "type": "image/png",',
  '      "purpose": "any"',
  "    }",
  "  ],",
  sprintf('  "theme_color": "%s",', field),
  sprintf('  "background_color": "%s",', field),
  '  "display": "standalone"',
  "}",
  ""
)
writeLines(manifest, "pkgdown/favicon/site.webmanifest")

message("wrote pkgdown/favicon/{favicon.svg,site.webmanifest}")
