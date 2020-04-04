library(readxl)
suppressPackageStartupMessages(library(tidyverse))
library(stringi)

################################
#'## List files
################################

files_there <- list.files("data_raw", pattern = "\\.xlsx$", full.names = TRUE) %>% 
  tibble(full_path=.) %>% 
  mutate(date = map_chr(full_path, ~str_extract(., "[0-9]{4}_[0-9]{1,2}_[0-9]{1,2}")) %>% 
           as.Date(format = "%Y_%m_%d")) %>% 
  arrange(date)


################################
#'## Read one
################################

path_doc_latest <- tail(files_there$full_path, 1)

################################
#'## Process sheet 5
################################

get_date_sheet <- function(path, sheet) {
  read_xlsx(path, sheet = sheet, n_max = 1) %>% 
    colnames() %>% 
    str_extract("2020-[0-9]{2}-[0-9]{2}")
}

## read sheet 5
read_process_generic <- function(path, sheet, n_max=Inf, col_types=NULL, col_names) {
  
  ## date
  doc_date <- get_date_sheet(path, sheet)
  read_xlsx(path, sheet = sheet, skip=6, n_max = n_max, 
            col_names = col_names,
            col_types=col_types) %>% 
    mutate(report_date = as.Date(doc_date))
}

read_process_sheet_1 <- function(path) {
  read_process_generic(path, sheet=1, n_max = Inf, 
                       col_names = c("date", "confirmed_cases")) %>% 
    mutate(date=as.Date(date))
}

read_process_sheet_2 <- function(path) {
  read_process_generic(path, sheet=2, n_max = 9, 
                       col_names = c("age_class", 
                                     "male_cases", "male_percent", "male_incidence",
                                     "female_cases", "female_percent", "female_incidence",
                                     "total_cases", "total_percent"))
}

read_process_sheet_3 <- function(path) {
  read_process_generic(path, sheet=3, n_max = 27, 
                       col_names = c("canton", 
                                     "confirmed_cases", "incidence"))
}

read_process_sheet_4 <- function(path) {
  read_process_generic(path, sheet=4, n_max = 9, 
                       col_names = c("age_class", 
                                     "male_hospitalised", "female_hospitalised", "total_hospitalised"))
}

read_process_sheet_5 <- function(path) {
  read_process_generic(path, sheet=5, n_max = 6, 
                       col_names = c("age_class", "male_deceased", "female_deceased", "total_deceased"))
}



## TEST
if(FALSE) {
  read_process_sheet_1(path_doc_latest) 
  read_process_sheet_2(path_doc_latest)
  read_process_sheet_3(path_doc_latest) %>%  tail
  read_process_sheet_4(path_doc_latest)
  read_process_sheet_5(path_doc_latest)
}


################################
#'## Do for all
################################

do_all_write <- function(sheet = 1, write=TRUE, name_out=paste0("sheet_", sheet),
                         postfix=NULL) {
  fo_char <- paste0("read_process_sheet_", sheet)
  fo <- eval(parse(text=fo_char))

  all <- files_there %>% 
    mutate(sheet = map(full_path, fo)) %>% 
    select(sheet) %>% 
    unnest(sheet)
  if(write) {
    file_out <- paste0("data_final/", name_out, postfix, ".csv")
    write_csv(all, file_out)
  }
  
}

do_all_write(sheet=1, postfix = "_byDate")
do_all_write(sheet=2, postfix = "_byAgeGender")
do_all_write(sheet=3, postfix = "_byCanton")
do_all_write(sheet=4, postfix = "_hospitalised")
do_all_write(sheet=5, postfix = "_deceased")

