suppressPackageStartupMessages({
  library(dplyr)
  library(readxl)
  library(stringr)
  library(tidyr)
})

feor93_08_crosswalk <-
  read_excel(
    here::here("data-raw/feor08_fordito.xls"),
    skip = 2,
    col_names = c("kod_4jegy_93", "nev_4jegy_93",
                  "kod_4jegy_08", "nev_4jegy_08")
  ) %>%
  select(starts_with("kod")) %>%
  mutate(
    across(everything(), as.character),
    # The excel sheet has numeric data with some special formatting,
    # we need to convert military occupations to a proper 4 digit
    # code.
    across(everything(), ~ str_pad(.x, width = 4, side = "left", pad = "0"))
  ) %>%
  fill(everything(), .direction = "down")

usethis::use_data(feor93_08_crosswalk, overwrite = TRUE)
