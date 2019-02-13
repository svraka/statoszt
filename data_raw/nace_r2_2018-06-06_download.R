library(eurostat)

nace <- get_eurostat_dic("nace_r2")

saveRDS(nace, "data_raw/nace_r2_2018-06-06.Rdata")
