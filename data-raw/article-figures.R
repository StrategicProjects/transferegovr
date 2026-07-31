# Gera as figuras de vignettes/articles/investimentos-pernambuco.Rmd.
#
#   Rscript data-raw/article-figures.R
#
# As figuras sao pre-renderizadas e versionadas porque os chunks do artigo
# usam eval = FALSE: avalia-los faria cada build do site baixar ~700 paginas
# das APIs do governo. Este script espera os RDS da extracao em `S`.
# Refazer a extracao muda os numeros -- atualize tambem o texto do artigo.

suppressMessages({library(dplyr); library(sf); library(ggplot2); library(scales)})
S <- "/private/tmp/claude-501/-Users-leite-Github-transferegovr/08accff3-e47d-480d-978a-9f709ddb8c5a/scratchpad"
OUT <- "/Users/leite/Github/transferegovr/vignettes/articles/figures"
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
sf_use_s2(FALSE)

navy <- "#0A2540"; green <- "#3FD98A"; blue <- "#2E6FD9"; red <- "#E1493B"

tema <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", colour = navy, size = 14),
    plot.subtitle = element_text(colour = "#4A6076", size = 10.5),
    plot.caption = element_text(colour = "#7A8B9C", size = 8.5, hjust = 0),
    panel.grid.minor = element_blank(),
    axis.title = element_text(colour = "#4A6076", size = 9)
  )

# --- 1. Ritmo: cadastros por ano ------------------------------------------
p <- readRDS(file.path(S, "pe_proj.rds"))
`%||%` <- function(x, y) if (is.null(x)) y else x
p$vl <- vapply(p$investimentos_previstos, function(x) if (length(x) == 0) NA_real_ else
  sum(vapply(x, function(y) as.numeric(y$vl_investimento_previsto %||% NA), numeric(1)),
      na.rm = TRUE), numeric(1))

ritmo <- p |> filter(!is.na(ano_cadastro)) |>
  group_by(ano = ano_cadastro) |>
  summarise(projetos = n(), bi = sum(vl, na.rm = TRUE) / 1e9)

ritmo <- ritmo |> mutate(
  rotulo = paste0(ano, "\nR$ ", number(bi, accuracy = 0.1, decimal.mark = ","), " bi"),
  parcial = ano == 2026
)

g1 <- ggplot(ritmo, aes(reorder(rotulo, ano), projetos)) +
  geom_col(aes(fill = parcial), width = 0.68, show.legend = FALSE) +
  scale_fill_manual(values = c("FALSE" = blue, "TRUE" = "#9FB6C9")) +
  geom_text(aes(label = comma(projetos, big.mark = ".", decimal.mark = ",")),
            vjust = -0.5, size = 3.4, colour = navy, fontface = "bold") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
  labs(
    title = "O cadastro acelerou; o investimento previsto seguiu outro compasso",
    subtitle = "Projetos do ObrasGov com Pernambuco como UF principal, por ano de cadastro",
    x = NULL, y = "projetos cadastrados",
    caption = paste0("Fonte: API ObrasGov, extracao de 31/07/2026. Valor = investimento previsto ",
                     "informado no cadastro.\n2026 em cinza: ano incompleto, dados ate 30/07.")
  ) + tema
ggsave(file.path(OUT, "ritmo.png"), g1, width = 8, height = 4.2, dpi = 150, bg = "white")

# --- 2. Mapa: onde os pontos realmente caem -------------------------------
hit <- readRDS(file.path(S, "hit.rds"))
mun <- readRDS(file.path(S, "mun.rds")) |> st_make_valid() |> st_transform(4326)
pe <- mun |> filter(abbrev_state == "PE") |> st_union()
br <- mun |> group_by(abbrev_state) |> summarise(.groups = "drop")

h <- hit |> mutate(
  classe = case_when(
    is.na(uf_real) ~ "fora de qualquer municipio",
    uf_real != "PE" ~ "em outro estado",
    TRUE ~ "em Pernambuco"
  )
)
fora <- h |> filter(classe != "em Pernambuco")

g2 <- ggplot() +
  geom_sf(data = br, fill = "#F2F5F8", colour = "#D3DCE5", linewidth = 0.2) +
  geom_sf(data = pe, fill = "#DCEAF7", colour = blue, linewidth = 0.5) +
  geom_sf(data = st_as_sf(fora), aes(colour = classe), size = 1.9, alpha = 0.85) +
  scale_colour_manual(values = c("em outro estado" = red,
                                 "fora de qualquer municipio" = "#F2A03D"), name = NULL) +
  coord_sf(xlim = c(-73, -31), ylim = c(-20, 2), expand = FALSE) +
  labs(
    title = "Obras declaradas em Pernambuco, plotadas fora dele",
    subtitle = "193 dos 8.146 pontos com coordenada caem fora do estado ou fora de qualquer municipio",
    caption = "Fonte: API ObrasGov (pins dos projetos) sobre malha municipal do IBGE 2022, via geobr. Extração de 31/07/2026."
  ) + tema +
  theme(legend.position = "bottom", axis.text = element_text(size = 7),
        panel.grid.major = element_line(colour = "#EDF1F5"))
ggsave(file.path(OUT, "mapa.png"), g2, width = 8, height = 5.4, dpi = 150, bg = "white")

# --- 3. A que distancia do municipio declarado ----------------------------
pj <- readRDS(file.path(S, "por_projeto.rds"))
faixas <- tibble(
  faixa = factor(c("< 1 km", "1-5 km", "5-25 km", "25-100 km", "100-500 km", "> 500 km"),
                 levels = c("< 1 km", "1-5 km", "5-25 km", "25-100 km", "100-500 km", "> 500 km")),
  projetos = c(39, 3, 4, 5, 1, 2)
)
g3 <- ggplot(faixas, aes(faixa, projetos)) +
  geom_col(aes(fill = faixa == "< 1 km"), width = 0.68, show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "#9FB6C9", "FALSE" = red)) +
  geom_text(aes(label = projetos), vjust = -0.5, size = 3.6, colour = navy, fontface = "bold") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.16))) +
  labs(
    title = "A maioria dos \"erros\" e imprecisao de fronteira",
    subtitle = "Distancia entre o ponto e o municipio que o projeto declara — 54 projetos de Pernambuco",
    x = NULL, y = "projetos",
    caption = "Em cinza, os que caem a menos de 1 km da divisa declarada. Em vermelho, os deslocamentos reais."
  ) + tema
ggsave(file.path(OUT, "distancias.png"), g3, width = 8, height = 4, dpi = 150, bg = "white")

cat("figuras escritas em", OUT, "\n")
print(list.files(OUT))
cat("\nconferencia do subtitulo do mapa: fora =", nrow(fora), "de", nrow(h), "\n")
