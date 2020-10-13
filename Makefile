.PHONY: rdas document

all: rdas document

rdas = data/feor93_2015_05_19.rda data/feor08_2019_02_14.rda data/gfo17_2018_07_26.rda data/teaor08_2018_09_01.rda
rdas: $(rdas)

data/feor93_2015_05_19.rda: data-raw/feor93.R data-raw/feor93_hu.html data-raw/feor93_en.html
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/feor08_2019_02_14.rda: data-raw/feor08_2019_02_14.R data-raw/feorlista_2019_02_14.html data-raw/feor_08_struktura_eng_2018-07-27.txt
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/gfo17_2018_07_26.rda: data-raw/gfo17_2018_07_26.R data-raw/tabula-gfo2017_struktura_2018_07_26.csv
	Rscript -e 'source("$<", encoding = "UTF-8")'

data/teaor08_2018_09_01.rda: data-raw/teaor08_2018_09_01.R data-raw/teaor08_struktura_2018_09_01.xls data-raw/tabula-NGM_37_2015_utmutato_2_melleklet.csv data-raw/a38_9900.csv data-raw/nace_r2_2018_06_06.RData
	Rscript -e 'source("$<", encoding = "UTF-8")'

document:
	Rscript -e 'devtools::document()'
