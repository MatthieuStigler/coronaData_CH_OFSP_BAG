library(rvest)
library(readxl)
library(tidyverse)     
library(stringi)

################################
#'## Get link (might change?)
################################

page <- read_html("https://www.bag.admin.ch/bag/fr/home/krankheiten/ausbrueche-epidemien-pandemien/aktuelle-ausbrueche-epidemien/novel-cov/situation-schweiz-und-international.html#-2058401801")

links <- page %>% 
  html_nodes("a") %>% 
  html_attr('href') %>% 
  enframe(name=NULL, value="url") %>% 
  distinct()

link_xlsx <- links %>% 
  filter(str_detect(url, "xlsx")) %>% 
  mutate(url_full = paste0("https://www.bag.admin.ch", url))

# https://www.bag.admin.ch/dam/bag/fr/dokumente/mt/k-und-i/aktuelle-ausbrueche-pandemien/2019-nCoV/covid-19-datengrundlage-lagebericht.xlsx.download.xlsx/200325_base%20de%20donn%C3%A9es_graphiques_COVID-19-rapport.xlsx
# https://www.bag.admin.ch/dam/bag/fr/dokumente/mt/k-und-i/aktuelle-ausbrueche-pandemien/2019-nCoV/covid-19-datengrundlage-lagebericht.xlsx.download.xlsx/200325_base%20de%20donn%C3%A9es_graphiques_COVID-19-rapport.xlsx


################################
#'## Downlaod
################################


## Name out file
today <- Sys.Date()
file_out <- paste0("data_raw/OFSP_report_downloades_", str_replace_all(today, "-", "_"), ".xlsx")

## Download 
download.file(link_xlsx$url_full[[1]], file_out)

################################
#'## Read
################################

## read just actual date
doc_date <- read_xlsx(file_out, sheet = 5, n_max = 1) %>% 
  colnames() %>% 
  str_extract("2020-[0-9]{2}-[0-9]{2}")

## read sheet 5
doc <- read_xlsx(tmp_file, sheet = 5, skip=5, n_max = 6)

## Clean
doc_clean <- doc %>% 
  setNames(c("age_class", "male_deceased", "female_deceased", "total_deceased")) %>% 
  mutate(date = as.Date(doc_date))

doc_clean

################################
#'## Export
################################

write_csv(doc_clean, "data_final/sheet_5_deceased_by_age.csv",
          append = today != doc_date)
