library(eurostat)

isco08 <- get_eurostat_dic("isco08")

saveRDS(nace, "data_raw/isco08_2017_07_24.Rdata")
