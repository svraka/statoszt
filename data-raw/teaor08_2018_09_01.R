suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(data.table))

# Hungarian table

teaor08_2018_09_01 <- read_excel(
  path = "data-raw/teaor08_struktura_2018_09_01.xls",
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
  file = "data-raw/tabula-NGM_37_2015_utmutato_2_melleklet.csv",
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

a38_9900 <- read_csv(
  "data-raw/a38_9900.csv",
  col_types = "ccii"
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


# English table. HCSO doesn't have a machine readable English
# translation, so we use Eurostat's NACE coding, which is identical to
# TEÁOR.

nace_r2_2018_06_06_raw <- read_rds("data-raw/nace_r2_2018_06_06.RData")

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

teaor_a38 <- teaor08_2018_09_01 %>%
  select(kod_a38, kod_2jegy) %>%
  group_by(kod_a38) %>%
  summarise(
    osztaly_kezd = min(kod_2jegy),
    osztaly_zaro = max(kod_2jegy),
    .groups = "drop"
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
         kod_a38, nev_a38, kod_a11, nev_a11) %>%
  mutate_at(vars(starts_with("nev")), as_factor) %>%
  rename_with(~ paste0(.x, "_eng"), contains("nev"))


# Join the two languages

# Check that we have identical structures
stopifnot(identical(teaor08_2018_09_01 %>% select(starts_with("kod")),
                    nace_r2_2018_06_06 %>% select(starts_with("kod"))))

# Add English labels
teaor08_2018_09_01 <- teaor08_2018_09_01 %>%
  left_join(nace_r2_2018_06_06,
            by = c("kod_4jegy", "kod_3jegy", "kod_2jegy", "kod_a38", "kod_a11")) %>%
  select(kod_4jegy, nev_4jegy, nev_4jegy_eng,
         kod_3jegy, nev_3jegy, nev_3jegy_eng,
         kod_2jegy, nev_2jegy, nev_2jegy_eng,
         kod_a38, nev_a38, nev_a38_eng,
         kod_a11, nev_a11, nev_a11_eng)


# Mentes

usethis::use_data(teaor08_2018_09_01, overwrite = TRUE)
