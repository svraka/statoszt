suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rvest))

feor08_2019_02_14 <- read_html(
  "data-raw/feorlista_2019_02_14.html",
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
  separate(value, into = c("kod_3jegy", "nev_3jegy"), sep = " ", extra = "merge") %>%
  mutate(
    nev_3jegy = str_to_sentence(nev_3jegy),
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
  separate(value, into = c("kod_4jegy", "nev_4jegy"), sep = " ", extra = "merge") %>%
  mutate(
    # Fix a few typos
    nev_4jegy = str_replace(nev_4jegy, "\\b[pP][rR]\\b", "PR"),
    # Create a key
    kod_3jegy = str_sub(kod_4jegy, 1, 3),
  ) %>%
  filter(str_detect(kod_4jegy, re_kod_4jegy))


# Osszekapcsolas

feor08_2019_02_14 <- foglalkozasok %>%
  left_join(csoportok, by = "kod_3jegy")


# English labels

# File name is based on modification date of the PDF original but
# there were no changes between this and the name of the exported data
# frame.

feor08_eng_2019_02_14 <- read_lines("data-raw/feor_08_struktura_eng_2018-07-27.txt") %>%
  str_split("\\ ", n = 2) %>%
  map_dfr(~ tibble(kod_4jegy = .x[[1]], nev_4jegy_eng = .x[[2]])) %>%
  mutate(
    # Fix a few typos
    nev_4jegy_eng = str_replace(nev_4jegy_eng, "([Mm])anegers", "\\1anagers"),
    nev_4jegy_eng = str_replace(nev_4jegy_eng, "LIght", "Light"),
    # And create 1, 2, and 3 digit codes and names
    kod_3jegy = if_else(
      str_detect(kod_4jegy, re_kod_3jegy),
      str_sub(kod_4jegy, 1, 3),
      NA_character_
    ),
    nev_3jegy_eng = if_else(
      str_detect(kod_4jegy, re_kod_3jegy),
      nev_4jegy_eng,
      NA_character_
    ),
    kod_2jegy = if_else(
      str_detect(kod_4jegy, re_kod_2jegy),
      str_sub(kod_4jegy, 1, 2),
      NA_character_
    ),
    nev_2jegy_eng = if_else(
      str_detect(kod_4jegy, re_kod_2jegy),
      nev_4jegy_eng,
      NA_character_
    ),
    kod_1jegy = if_else(
      str_detect(kod_4jegy, re_kod_1jegy),
      str_sub(kod_4jegy, 1, 1),
      NA_character_
    ),
    nev_1jegy_eng = if_else(
      str_detect(kod_4jegy, re_kod_1jegy),
      str_to_sentence(nev_4jegy_eng),
      NA_character_
    )
  ) %>%
  fill(kod_3jegy, nev_3jegy_eng, kod_2jegy, nev_2jegy_eng,
       kod_1jegy, nev_1jegy_eng) %>%
  filter(str_length(kod_4jegy) == 4)

# Check that we have the same tables in both languages
stopifnot(nrow(feor08_2019_02_14) == nrow(feor08_eng_2019_02_14))

feor08_2019_02_14 <- feor08_2019_02_14 %>%
  left_join(feor08_eng_2019_02_14,
            by = c("kod_4jegy", "kod_3jegy", "kod_2jegy", "kod_1jegy")) %>%
  select(kod_4jegy, nev_4jegy, nev_4jegy_eng,
         kod_3jegy, nev_3jegy, nev_3jegy_eng,
         kod_2jegy, nev_2jegy, nev_2jegy_eng,
         kod_1jegy, nev_1jegy, nev_1jegy_eng) %>%
  mutate(across(starts_with("nev"), as_factor))


# Mentes

usethis::use_data(feor08_2019_02_14, overwrite = TRUE)
