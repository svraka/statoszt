suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(data.table))

teaor08_2018_09_01 <- read_excel(
  path = "data_raw/teaor08_struktura_2018_09_01.xls",
  range = "A3:B998", # Nem az elso sorban kezdodik, az utolso sor ures es vannak
                     # rejtett oszlopok
  col_names = c("kod", "nev")
)


# 2-, 3- es 4-jegy kodok es nevek szetvalasztasa

re_kod_a11   <- "^[A-Z]"
re_kod_2jegy <- "^\\d{2}$"
re_kod_3jegy <- "^\\d{3}$"
re_kod_4jegy <- "^\\d{4}$"

teaor08_2018_09_01 <- teaor08_2018_09_01 %>%
  # Meg vannak csillagozva a kisker 3-jegy sorok
  mutate(
    kod = str_remove(kod, fixed("*"))
  ) %>%
  mutate(
    kod_a11   = if_else(str_detect(kod, re_kod_a11),   kod, NA_character_),
    nev_a11   = if_else(str_detect(kod, re_kod_a11),   nev, NA_character_),
    kod_2jegy = if_else(str_detect(kod, re_kod_2jegy), kod, NA_character_),
    nev_2jegy = if_else(str_detect(kod, re_kod_2jegy), nev, NA_character_),
    kod_3jegy = if_else(str_detect(kod, re_kod_3jegy), kod, NA_character_),
    nev_3jegy = if_else(str_detect(kod, re_kod_3jegy), nev, NA_character_)
  ) %>%
  fill(-kod, -nev) %>%
  filter(str_detect(kod, re_kod_4jegy)) %>%
  mutate(
    nev_a11 = str_to_sentence(nev_a11)
  ) %>%
  rename(
    kod_4jegy = kod,
    nev_4jegy = nev
  ) %>%
  mutate(
    kod_2jegy_num = as.integer(kod_2jegy)
  )


# A38 kodok

a38 <- read_csv(
  file = "data_raw/tabula-NGM_37_2015_utmutato_2_melleklet.csv",
  col_names = c("kod_a38", "nev_a38", "osztaly"),
  skip = 1,
  col_types = "ccc"
)

a38 <- a38 %>%
  # Egybetusitjuk, ha a foagazaton belul nincs alkategoria
  mutate(
    foagazat = str_sub(kod_a38, 1, 1)
  ) %>%
  group_by(foagazat) %>%
  mutate(
    n_alagazat = n()
  ) %>%
  ungroup %>%
  mutate(
    kod_a38 = if_else(n_alagazat == 1, foagazat, kod_a38)
  ) %>%
  select(-foagazat, -n_alagazat) %>%
  # Osztalyok kezdo es zaro ketjegyu kodja
  mutate(
    osztaly_kezd = as.integer(str_replace(osztaly, "^(\\d{2}).*",  "\\1")),
    osztaly_zaro = as.integer(str_replace(osztaly, "^.*(\\d{2})$", "\\1"))
  ) %>%
  select(-osztaly)

# A 9900-nek nincs A38 kodja, kezzel feltoltjuk

a38_9900 <- tibble(
  kod_a38      = "U",
  nev_a38      = "Területen kívüli szervezet",
  osztaly_kezd = 99L,
  osztaly_zaro = 99L,
)

a38 <- a38 %>%
  bind_rows(a38_9900)


# Non-equi joinnal a `data.table`-bol osszakapcsoljuk

t <- teaor08_2018_09_01 %>%
  select(kod_2jegy, kod_2jegy_num) %>%
  distinct

setDT(t)
setDT(a38)

t <- t[
  a38,
  on = .(kod_2jegy_num >= osztaly_kezd, kod_2jegy_num <= osztaly_zaro)
]

t <- t %>%
  as_tibble %>%
  select(kod_2jegy, kod_a38, nev_a38)


# Visszakapcsoljuk a fo tablahoz

teaor08_2018_09_01 <- teaor08_2018_09_01 %>%
  left_join(t, by = "kod_2jegy") %>%
  select(kod_4jegy, nev_4jegy, kod_3jegy, nev_3jegy, kod_2jegy, nev_2jegy,
         kod_a38, nev_a38, kod_a11, nev_a11) %>%
  mutate_at(vars(starts_with("nev")), as_factor)


# Mentes

saveRDS(teaor08_2018_09_01, "data/teaor08_2018_09_01.Rdata")
