suppressPackageStartupMessages(library(rvest))
library(readxl)
suppressPackageStartupMessages(library(tidyverse))
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
#'## Downlaod to temp file
################################

## Download 
tmp_file <- tempfile()
download.file(link_xlsx$url_full[[1]], tmp_file, quiet=TRUE)

################################
#'## Check if is update
################################

## read just actual date
doc_date <- read_xlsx(tmp_file, sheet = 1, n_max = 1) %>% 
  colnames() %>% 
  str_extract("202[0-1]-[0-9]{2}-[0-9]{2}")

## last date available
files_there <- list.files("data_raw", pattern = "\\.xlsx$")
files_there_dates <- str_extract(files_there, "[0-9]{4}_[0-9]{1,2}_[0-9]{1,2}") %>% 
  as.Date(format = "%Y_%m_%d")

latest_there <- max(files_there_dates)

## 
is_update <- doc_date >  latest_there


################################
#'## Save if update
################################

if(is_update) {
  file_out <- paste0("data_raw/OFSP_report_downloaded_", str_replace_all(doc_date, "-", "_"), ".xlsx")  
  # file.exists(tmp_file)
  file.copy(tmp_file, file_out, overwrite = TRUE) # in theory overwrite not needed!
  print("Update")
} else {
  print("No update")
}
