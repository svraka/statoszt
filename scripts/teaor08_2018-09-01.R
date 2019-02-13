library(dplyr)
library(stringr)
library(readxl)

teaor08_2018_09_01 <- read_excel(
  path = "data_raw/teaor08_struktura_2018_09_01.xls",
  range = "A3:B998", # Nem az elso sorban kezdodik, az utolso sor ures es vannak
                     # rejtett oszlopok
  col_names = c("kod", "nev")
)


# 2-, 3- es 4-jegy kodok es nevek szetvalasztasa

teaor08_2018_09_01 <- teaor08_2018_09_01 %>%
  mutate(
    kod_a11   = if_else(str_detect(kod, "^[A-Z]"),   kod, NA_character_),
    nev_a11   = if_else(str_detect(kod, "^[A-Z]"),   nev, NA_character_),
    kod_2jegy = if_else(str_detect(kod, "^\\d{2}$"), kod, NA_character_),
    nev_2jegy = if_else(str_detect(kod, "^\\d{2}$"), nev, NA_character_),
    kod_3jegy = if_else(str_detect(kod, "^\\d{3}$"), kod, NA_character_),
    nev_3jegy = if_else(str_detect(kod, "^\\d{3}$"), nev, NA_character_)
  ) %>%
  fill(-kod, -nev) %>%
  filter(str_detect(kod, "^\\d{4}$")) %>%
  mutate(
    nev_a11 = str_to_sentence(nev_a11)
  ) %>%
  select(kod_a11:nev_3jegy, kod_4jegy = kod, nev_4jegy = nev)


# Mentes

saveRDS(teaor08_2018_09_01, "data/teaor08_2018_09_01.Rdata")
