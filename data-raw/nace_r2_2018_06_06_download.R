library(eurostat)

nace <- get_eurostat_dic("nace_r2")

saveRDS(nace, "data-raw/nace_r2_2018_06_06.RData")
