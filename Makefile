.PHONY: rdatas

scripts = $(wildcard scripts/*.R)
rdatas = $(subst scripts/, data/, $(addsuffix .Rdata, $(basename $(scripts))))

rdatas: $(rdatas)

data/feor08_2019_02_14.Rdata: scripts/feor08_2019_02_14.R data_raw/feorlista_2019_02_14.html
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/gfo17_2018_07_26.Rdata: scripts/gfo17_2018_07_26.R data_raw/tabula-gfo2017_struktura_2018_07_26.csv
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/isco08_2017_07_24.Rdata: scripts/isco08_2017_07_24.R data_raw/isco08_2017_07_24.Rdata
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/nace_r2_2018_06_06.Rdata: scripts/nace_r2_2018_06_06.R data_raw/nace_r2_2018_06_06.Rdata data/teaor08_2018_09_01.Rdata
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/teaor08_2018_09_01.Rdata: scripts/teaor08_2018_09_01.R data_raw/teaor08_struktura_2018_09_01.xls data_raw/tabula-NGM_37_2015_utmutato_2_melleklet.csv
	Rscript -e 'source("$<", encoding = "UTF-8")'
