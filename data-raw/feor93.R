suppressPackageStartupMessages({
  library(dplyr)
  library(purrr)
  library(stringr)
  library(tibble)
  library(tidyr)
  library(forcats)
  library(rvest)
})

re_kod_4jegy <- "^\\d{4}$"
re_kod_3jegy <- "^\\d{3}$"
re_kod_2jegy <- "^\\d{2}$"
re_kod_1jegy <- "^\\d{1}$"

feor93_2015_05_19 <- c("feor93_hu.html", "feor93_en.html") %>%
  here::here("data-raw", .) %>%
  set_names(~ str_replace(.x, ".+feor93_(.+?)\\..+", "\\1")) %>%
  map(
    ~ read_html(.x) %>%
      html_nodes(".elem") %>%
      html_text() %>%
      enframe(name = NULL) %>%
      separate(col = value, into = c("kod_4jegy", "nev_4jegy"), sep = " ",
               extra = "merge", fill = "right") %>%
      # Filter out unknown codes, for some reason they included them. Also
      # filter out "Közületi eltartott" (some dependent person?) which is
      # not a valid code.
      filter(!(kod_4jegy %in% c("0000", "9998", "9999"))) %>%
      # There are some 3 digit codes that span multiple (in all cases 2) 3
      # digits numbers, presumably because there are more than 10
      # different 4 digit occupations in a single category. We keep all of
      # them, in case we need to label a dataset with 3 digit codes. As
      # the range is always 2, we can simply separate on `-`.
      separate_rows(kod_4jegy, sep = "-") %>%
      # And then rearrange the table so that occupations in the second 3
      # digit group can be paired to their labels when filling down. We
      # also sort military occupations to the bottom, as it is done on
      # FEOR08.
      mutate(kod_4jegy = if_else(str_detect(kod_4jegy, "^0"),
                                 paste0("B", kod_4jegy),
                                 paste0("A", kod_4jegy))) %>%
      arrange(kod_4jegy) %>%
      mutate(kod_4jegy = str_sub(kod_4jegy, 2)) %>%
      mutate(
        nev_4jegy = str_to_sentence(nev_4jegy),
        kod_3jegy = if_else(
          str_detect(kod_4jegy, re_kod_3jegy),
          str_sub(kod_4jegy, 1, 3),
          NA_character_
        ),
        nev_3jegy = if_else(
          str_detect(kod_4jegy, re_kod_3jegy),
          nev_4jegy,
          NA_character_
        ),
        kod_2jegy = if_else(
          str_detect(kod_4jegy, re_kod_2jegy),
          str_sub(kod_4jegy, 1, 2),
          NA_character_
        ),
        nev_2jegy = if_else(
          str_detect(kod_4jegy, re_kod_2jegy),
          nev_4jegy,
          NA_character_
        ),
        kod_1jegy = if_else(
          str_detect(kod_4jegy, re_kod_1jegy),
          str_sub(kod_4jegy, 1, 1),
          NA_character_
        ),
        nev_1jegy = if_else(
          str_detect(kod_4jegy, re_kod_1jegy),
          nev_4jegy,
          NA_character_
        )
      ) %>%
      fill(kod_3jegy, nev_3jegy, kod_2jegy, nev_2jegy, kod_1jegy, nev_1jegy) %>%
      filter(str_length(kod_4jegy) == 4)
  )

feor93_2015_05_19$en <- feor93_2015_05_19$en %>%
  rename_with(~ paste0(.x, "_eng"), .cols = starts_with("nev"))

# Check that we have the same tables in both languages
stopifnot(nrow(feor93_2015_05_19$hu) == nrow(feor93_2015_05_19$hu))

feor93_2015_05_19 <- reduce(feor93_2015_05_19, left_join,
                 by = c("kod_4jegy", "kod_3jegy", "kod_2jegy", "kod_1jegy")) %>%
  select(kod_4jegy, nev_4jegy, nev_4jegy_eng,
         kod_3jegy, nev_3jegy, nev_3jegy_eng,
         kod_2jegy, nev_2jegy, nev_2jegy_eng,
         kod_1jegy, nev_1jegy, nev_1jegy_eng) %>%
  mutate(across(starts_with("nev"), as_factor))

# Save

usethis::use_data(feor93_2015_05_19, overwrite = TRUE)
