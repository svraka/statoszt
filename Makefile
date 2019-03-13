.PHONY: rdatas

scripts = $(wildcard scripts/*.R)
rdatas = $(subst scripts/, data/, $(addsuffix .Rdata, $(basename $(scripts))))

rdatas: $(rdatas)

data/feor08_2019-02-14.Rdata: scripts/feor08_2019-02-14.R data_raw/feorlista_2019-02-14.html
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/gfo17_2018-07-26.Rdata: scripts/gfo17_2018-07-26.R data_raw/tabula-gfo2017_struktura_2018-07-26.csv
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/isco08_2017-07-24.Rdata: scripts/isco08_2017-07-24.R data_raw/isco08_2017-07-24.Rdata
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/nace_r2_2018-06-06.Rdata: scripts/nace_r2_2018-06-06.R data_raw/nace_r2_2018-06-06.Rdata data/teaor08_2018-09-01.Rdata
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/teaor08_2018-09-01.Rdata: scripts/teaor08_2018-09-01.R data_raw/teaor08_struktura_2018_09_01.xls data_raw/tabula-NGM_37_2015_utmutato_2_melleklet.csv
	Rscript -e 'source("$<", encoding = "UTF-8")'
