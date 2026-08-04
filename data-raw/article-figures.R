# Gera as figuras de vignettes/articles/investimentos-pernambuco.Rmd.
#
#   Rscript data-raw/article-figures.R
#
# As figuras sao pre-renderizadas e versionadas porque os chunks do artigo usam
# eval = FALSE: avalia-los faria cada build do site baixar milhares de linhas
# das APIs do governo. Este script faz a propria extracao, entao reproduz as
# figuras do zero -- e leva alguns minutos.
#
# Refazer a extracao muda os numeros. Atualize tambem o texto do artigo e os
# textos alternativos das imagens, que citam valores.
#
# O diagrama da trilha do dinheiro (trilha-do-dinheiro.svg) e escrito a mao e
# nao passa por aqui.

suppressMessages({
  library(transferegovr)
  library(obrasgovr)
  library(dplyr)
  library(tidyr)
  library(sf)
  library(geobr)
  library(ggplot2)
  library(scales)
})

sf_use_s2(FALSE)

saida <- "vignettes/articles/figures"
dir.create(saida, recursive = TRUE, showWarnings = FALSE)

navy <- "#0A2540"
blue <- "#2E6FD9"
red <- "#E1493B"

tema <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", colour = navy, size = 14),
    plot.subtitle = element_text(colour = "#4A6076", size = 10.5),
    plot.caption = element_text(colour = "#7A8B9C", size = 8.5, hjust = 0),
    panel.grid.minor = element_blank(),
    axis.title = element_text(colour = "#4A6076", size = 9),
    legend.position = "top",
    legend.title = element_blank()
  )

# 1. O ritmo das transferencias especiais -------------------------------------

# O plano de acao nao carrega mais a UF: ela vive no beneficiario, entao o
# recorte por estado e uma juncao e nao um filtro. E "impedido" aparece com
# duas grafias, uma delas em caixa alta, por isso o teste ignora maiusculas.
pe <- tg_get("especiais", "beneficiarios_especiais", .limit = Inf) |>
  filter(uf_beneficiario == "PE")

planos <- tg_get("especiais", "planos_acao_especiais", .limit = Inf) |>
  semi_join(pe, by = "id_beneficiario") |>
  mutate(
    valor = coalesce(valor_custeio_plano_acao, 0) +
      coalesce(valor_investimento_plano_acao, 0),
    status = ifelse(
      grepl("impedid", situacao_plano_acao, ignore.case = TRUE),
      "impedido", "seguiu adiante"
    )
  )

por_ano <- planos |>
  group_by(ano = ano_plano_acao, status) |>
  summarise(milhoes = sum(valor) / 1e6, planos = n(), .groups = "drop")

totais <- por_ano |>
  group_by(ano) |>
  summarise(milhoes = sum(milhoes), planos = sum(planos))

ritmo <- ggplot(por_ano, aes(factor(ano), milhoes, fill = status)) +
  geom_col(width = 0.68) +
  scale_fill_manual(values = c("seguiu adiante" = blue, "impedido" = red)) +
  geom_text(
    data = totais,
    aes(factor(ano), milhoes, label = paste(planos, "planos")),
    inherit.aes = FALSE, vjust = -0.6, size = 3.2,
    colour = navy, fontface = "bold"
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.16)),
    labels = function(x) paste0("R$ ", number(x, big.mark = "."), " mi")
  ) +
  labs(
    title = "Transferencias especiais para Pernambuco, por ano do plano",
    subtitle = paste0(
      "R$ 1,71 bilhao em 1.962 planos; ",
      "R$ 151,8 milhoes nunca passaram do empenho"
    ),
    x = NULL, y = NULL,
    caption = paste0(
      "Fonte: API TransfereGov, modulo especiais, ",
      "extracao de 03/08/2026.\n",
      "2026 e ano incompleto. Valor = custeio mais investimento do plano."
    )
  ) +
  tema

ggsave(
  file.path(saida, "especiais-ritmo.png"), ritmo,
  width = 8, height = 4.6, dpi = 150, bg = "white"
)

# 2. Onde os pontos do ObrasGov realmente caem --------------------------------

projetos <- get_projects(
  uf_principal = "PE", page_size = 200, all_pages = TRUE
)

coordenada <- function(pin, campo) {
  valor <- pin[[campo]]
  if (is.null(valor)) NA_character_ else as.character(valor)
}

pins <- projetos |>
  select(id_projeto_investimento, pins) |>
  filter(lengths(pins) > 0) |>
  unnest_longer(pins) |>
  mutate(
    lat = suppressWarnings(as.numeric(
      vapply(pins, coordenada, character(1), "latitude")
    )),
    lon = suppressWarnings(as.numeric(
      vapply(pins, coordenada, character(1), "longitude")
    ))
  ) |>
  filter(!is.na(lat), !is.na(lon)) |>
  select(-pins)

municipios <- read_municipality(year = 2022, showProgress = FALSE) |>
  st_make_valid() |>
  st_transform(4326)

onde_caem <- pins |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE) |>
  st_join(municipios[, "abbrev_state"], join = st_within) |>
  mutate(
    classe = case_when(
      is.na(abbrev_state) ~ "fora de qualquer municipio",
      abbrev_state != "PE" ~ "em outro estado",
      TRUE ~ "em Pernambuco"
    )
  )

fora <- onde_caem |> filter(classe != "em Pernambuco")
estados <- municipios |>
  group_by(abbrev_state) |>
  summarise(.groups = "drop")
pernambuco <- municipios |>
  filter(abbrev_state == "PE") |>
  st_union()

mapa <- ggplot() +
  geom_sf(
    data = estados, fill = "#F2F5F8", colour = "#D3DCE5", linewidth = 0.2
  ) +
  geom_sf(
    data = pernambuco, fill = "#DCEAF7", colour = blue, linewidth = 0.5
  ) +
  geom_sf(data = fora, aes(colour = classe), size = 1.9, alpha = 0.85) +
  scale_colour_manual(
    values = c(
      "em outro estado" = red,
      "fora de qualquer municipio" = "#F2A03D"
    ),
    name = NULL
  ) +
  coord_sf(xlim = c(-73, -31), ylim = c(-20, 2), expand = FALSE) +
  labs(
    title = "Obras declaradas em Pernambuco, plotadas fora dele",
    subtitle = paste0(
      nrow(fora), " dos ", nrow(onde_caem), " pontos com coordenada caem ",
      "fora do estado ou fora de qualquer municipio"
    ),
    caption = paste0(
      "Fonte: API ObrasGov (pins dos projetos) sobre malha municipal do ",
      "IBGE 2022, via geobr. Extracao de 31/07/2026."
    )
  ) +
  tema +
  theme(
    legend.position = "bottom",
    axis.text = element_text(size = 7),
    panel.grid.major = element_line(colour = "#EDF1F5")
  )

ggsave(
  file.path(saida, "mapa.png"), mapa,
  width = 8, height = 5.4, dpi = 150, bg = "white"
)

message("figuras escritas em ", saida)
message("pontos fora de PE: ", nrow(fora), " de ", nrow(onde_caem))
