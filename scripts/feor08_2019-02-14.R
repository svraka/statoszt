suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rvest))

feor08_2019_02_14 <- read_html(
  "data_raw/feorlista_2019-02-14.html",
  encoding = "windows-1250"
)

re_kod_4jegy <- "^\\d{4}$"
re_kod_3jegy <- "^\\d{3}$"
re_kod_2jegy <- "^\\d{2}$"
re_kod_1jegy <- "^\\d{1}$"


# Focsoportok feldolgozasa

csoportok <- feor08_2019_02_14 %>%
  html_nodes(".folder") %>%
  html_text %>%
  enframe(name = NULL) %>%
  separate(value, into = c("kod_3jegy", "nev_3jegy"), extra = "merge") %>%
  mutate(nev_3jegy = str_to_sentence(nev_3jegy)) %>%
  mutate(
    kod_2jegy = if_else(
      str_detect(kod_3jegy, re_kod_2jegy),
      str_sub(kod_3jegy, 1, 2),
      NA_character_
    ),
    nev_2jegy = if_else(
      str_detect(kod_3jegy, re_kod_2jegy),
      nev_3jegy,
      NA_character_
    ),
    kod_1jegy = if_else(
      str_detect(kod_3jegy, re_kod_1jegy),
      str_sub(kod_3jegy, 1, 1),
      NA_character_
    ),
    nev_1jegy = if_else(
      str_detect(kod_3jegy, re_kod_1jegy),
      nev_3jegy,
      NA_character_
    )
  ) %>%
  fill(-kod_3jegy, -nev_3jegy) %>%
  filter(str_detect(kod_3jegy, re_kod_3jegy))


# Foglalkozasok feldolgozasas

foglalkozasok <- feor08_2019_02_14 %>%
  html_nodes(".occ") %>%
  html_text %>%
  enframe(name = NULL) %>%
  separate(value, into = c("kod_4jegy", "nev_4jegy"), extra = "merge") %>%
  mutate(kod_3jegy = str_sub(kod_4jegy, 1, 3)) %>%
  filter(str_detect(kod_4jegy, re_kod_4jegy))


# Osszekapcsolas

feor08_2019_02_14 <- foglalkozasok %>%
  left_join(csoportok, by = "kod_3jegy")


# Mentes

saveRDS(feor08_2019_02_14, "data/feor08_2019-02-14.Rdata")
