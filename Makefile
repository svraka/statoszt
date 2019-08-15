.PHONY: rdas document

all: rdas document

rdas = data/feor08_2019_02_14.rda data/gfo17_2018_07_26.rda data/isco08_2017_07_24.rda data/nace_r2_2018_06_06.rda data/teaor08_2018_09_01.rda 
rdas: $(rdas)

data/feor08_2019_02_14.rda: data-raw/feor08_2019_02_14.R data-raw/feorlista_2019_02_14.html
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/gfo17_2018_07_26.rda: data-raw/gfo17_2018_07_26.R data-raw/tabula-gfo2017_struktura_2018_07_26.csv
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/isco08_2017_07_24.rda: data-raw/isco08_2017_07_24.R data-raw/isco08_2017_07_24.RData
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/nace_r2_2018_06_06.rda: data-raw/nace_r2_2018_06_06.R data-raw/nace_r2_2018_06_06.RData data/teaor08_2018_09_01.rda
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/teaor08_2018_09_01.rda: data-raw/teaor08_2018_09_01.R data-raw/teaor08_struktura_2018_09_01.xls data-raw/tabula-NGM_37_2015_utmutato_2_melleklet.csv
	Rscript -e 'source("$<", encoding = "UTF-8")'

document:
	Rscript -e 'devtools::document()'
