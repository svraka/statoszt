suppressPackageStartupMessages(library(tidyverse))

# Tabula nem tudta szepen megenni, kis kezi korrekciok

gfo17_2018_07_26 <- read_csv(
  file = "data_raw/tabula-gfo2017_struktura_2018-07-26.csv",
  skip = 3,
  col_names = c("kod", "nev"),
  col_types = "cc"
)

re_kod_1jegy <- "^\\d{1}$"
re_kod_2jegy <- "^\\d{2}$"
re_kod_3jegy <- "^\\d{3}$"


# Fokategoriak

fokategoriak <- gfo17_2018_07_26 %>%
  filter(str_detect(kod, "^[\\d,\\s]+$")) %>%
  filter(str_detect(kod, ",")) %>%
  mutate(kod = str_split(kod, pattern = ",\\ *")) %>%
  group_by(nev) %>%
  unnest %>%
  select(
    kod_1jegy = kod,
    nev_fokategoria = nev
  )


# 1-, 2- es 3-jegyu kodok es nevek szetvalasztasa

gfo17_2018_07_26 <- gfo17_2018_07_26 %>%
  # A tobbi osztalyt atfogo kategoriakat kulon kezeljuk
  filter(str_detect(kod, "^\\d+$")) %>%
  mutate(
    kod_2jegy = if_else(str_detect(kod, re_kod_2jegy), kod, NA_character_),
    nev_2jegy = if_else(str_detect(kod, re_kod_2jegy), nev, NA_character_),
    kod_1jegy = if_else(str_detect(kod, re_kod_1jegy), kod, NA_character_),
    nev_1jegy = if_else(str_detect(kod, re_kod_1jegy), nev, NA_character_)
  ) %>%
  fill(-kod, -nev) %>%
  filter(str_detect(kod, re_kod_3jegy)) %>%
  rename(
    kod_3jegy = kod,
    nev_3jegy = nev
  )


# Osszekapcsolas

gfo17_2018_07_26 <- gfo17_2018_07_26 %>%
  left_join(fokategoriak, by = "kod_1jegy") %>%
  mutate(nev_fokategoria = coalesce(nev_fokategoria, nev_1jegy)) %>%
  mutate_at(vars(starts_with("nev")), as_factor)


# Mentes

saveRDS(gfo17_2018_07_26, "data/gfo17_2018-07-26.Rdata")
