suppressPackageStartupMessages(library(tidyverse))

isco08_2017_07_24 <- read_rds("data_raw/isco08_2017-07-24.Rdata")

re_kod_4jegy <- "^OC\\d{4}$"
re_kod_3jegy <- "^OC\\d{3}$"
re_kod_2jegy <- "^OC\\d{2}$"
re_kod_1jegy <- "^OC\\d{1}$"

isco08_2017_07_24 <- isco08_2017_07_24 %>%
  filter(str_detect(code_name, "OC\\d+$")) %>%
  rename(kod_4jegy = code_name, nev_4jegy = full_name) %>%
  mutate(
    kod_3jegy = if_else(
      str_detect(kod_4jegy, re_kod_3jegy),
      str_sub(kod_4jegy, 3, 5),
      NA_character_
    ),
    nev_3jegy = if_else(
      str_detect(kod_4jegy, re_kod_3jegy),
      nev_4jegy,
      NA_character_
    ),
    kod_2jegy = if_else(
      str_detect(kod_4jegy, re_kod_2jegy),
      str_sub(kod_4jegy, 3, 4),
      NA_character_
    ),
    nev_2jegy = if_else(
      str_detect(kod_4jegy, re_kod_2jegy),
      nev_4jegy,
      NA_character_
    ),
    kod_1jegy = if_else(
      str_detect(kod_4jegy, re_kod_1jegy),
      str_sub(kod_4jegy, 3, 3),
      NA_character_
    ),
    nev_1jegy = if_else(
      str_detect(kod_4jegy, re_kod_1jegy),
      nev_4jegy,
      NA_character_
    )
  ) %>%
  fill(-kod_4jegy, -nev_4jegy) %>%
  filter(str_detect(kod_4jegy, re_kod_4jegy)) %>%
  mutate(kod_4jegy = str_sub(kod_4jegy, 3, 6)) %>%
  mutate_at(vars(starts_with("nev")), as_factor)

saveRDS(isco08_2017_07_24, "data/isco08_2017-07-24.Rdata")
