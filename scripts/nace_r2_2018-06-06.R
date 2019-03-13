library(data.table)
library(tidyverse)

nace_r2_2018_06_06_raw <- read_rds("data_raw/nace_r2_2018-06-06.Rdata")

re_kod_4jegy <- "^[A-Z]\\d{4}$"
re_kod_3jegy <- "^[A-Z]\\d{3}$"
re_kod_2jegy <- "^[A-Z]\\d{2}$"
re_kod_a11   <- "^[A-Z]$"

nace_r2_2018_06_06 <- nace_r2_2018_06_06_raw %>%
  mutate(
    kod_4jegy = if_else(
      str_detect(code_name, re_kod_4jegy),
      str_sub(code_name, 2),
      NA_character_
    ),
    nev_4jegy = if_else(
      str_detect(code_name, re_kod_4jegy),
      full_name,
      NA_character_
    ),
    kod_3jegy = if_else(
      str_detect(code_name, re_kod_3jegy),
      str_sub(code_name, 2),
      NA_character_
    ),
    nev_3jegy = if_else(
      str_detect(code_name, re_kod_3jegy),
      full_name,
      NA_character_
    ),
    kod_2jegy = if_else(
      str_detect(code_name, re_kod_2jegy),
      str_sub(code_name, 2),
      NA_character_
    ),
    nev_2jegy = if_else(
      str_detect(code_name, re_kod_2jegy),
      full_name,
      NA_character_
    ),
    kod_a11 = if_else(
      str_detect(code_name, re_kod_a11),
      code_name,
      NA_character_
    ),
    nev_a11 = if_else(
      str_detect(code_name, re_kod_a11),
      full_name,
      NA_character_
    )
  ) %>%
  fill(-code_name, -full_name) %>%
  filter(str_detect(code_name, re_kod_4jegy)) %>%
  select(-code_name, -full_name)

# A38 kodok

teaor_a38 <- read_rds("data/teaor08_2018-09-01.Rdata") %>%
  select(kod_a38, kod_2jegy) %>%
  group_by(kod_a38) %>%
  summarise(
    osztaly_kezd = min(kod_2jegy),
    osztaly_zaro = max(kod_2jegy)
  ) %>%
  filter(str_length(kod_a38) == 2)

# Tobb ketjegyu osztalyt felolelo A38-ak

re_kod_a38 <- "^([A-Z]\\d{2})[-_]([A-Z]\\d{2})$"

nace_a38 <- nace_r2_2018_06_06_raw %>%
  filter(str_detect(code_name, re_kod_a38)) %>%
  mutate(
    code_name = str_replace_all(code_name, re_kod_a38, "\\1_\\2")
  ) %>%
  separate(
    code_name,
    c("osztaly_kezd", "osztaly_zaro"),
    sep = "_"
  ) %>%
  mutate_at(
    vars(starts_with("osztaly")),
    ~str_remove(.x, "^[A-Z]")
  )

a38_1 <- teaor_a38 %>%
  filter(osztaly_kezd != osztaly_zaro) %>%
  left_join(nace_a38, by = c("osztaly_kezd", "osztaly_zaro")) %>%
  rename(nev_a38 = full_name)


# Csak egy osztalyt felolelo A38-ak

a38_2 <- teaor_a38 %>%
  filter(osztaly_kezd == osztaly_zaro) %>%
  left_join(
    nace_r2_2018_06_06 %>% select(kod_2jegy, nev_2jegy) %>% distinct,
    by = c("osztaly_kezd" = "kod_2jegy")
  ) %>%
  rename(nev_a38 = nev_2jegy)


# Teljes A38

a38 <- bind_rows(a38_1, a38_2) %>%
  arrange(kod_a38) %>%
  mutate_at(
    vars(starts_with("osztaly")),
    ~as.integer(.x)
  )


# Non-equi joinnal a `data.table`-bol osszakapcsoljuk

t <- nace_r2_2018_06_06 %>%
  select(kod_2jegy) %>%
  mutate(kod_2jegy_num = as.integer(kod_2jegy)) %>%
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

nace_r2_2018_06_06 <- nace_r2_2018_06_06 %>%
  left_join(t, by = "kod_2jegy") %>%
  mutate(
    kod_a38 = if_else(is.na(kod_a38), kod_a11, kod_a38),
    nev_a38 = if_else(is.na(nev_a38), nev_a11, nev_a38),
  ) %>%
  select(kod_4jegy, nev_4jegy, kod_3jegy, nev_3jegy, kod_2jegy, nev_2jegy,
         kod_a38, nev_a38, kod_a11, nev_a11)


# Mentes

saveRDS(nace_r2_2018_06_06, "data/nace_r2_2018-06-06.Rdata")
