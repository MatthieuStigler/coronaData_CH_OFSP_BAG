suppressPackageStartupMessages(library(tidyverse))

################################
#'## Read data
################################

## READ ALL
files_clean_list <- list.files("data_final", pattern = "\\.csv$", full.names = TRUE) %>% 
  tibble(full_path=.) %>% 
  mutate(sheet = map_chr(full_path, ~str_extract(., "(?<=sheet_)[0-9]") %>% 
           as.integer),
         data = map(full_path, ~read_csv(., col_types = cols()))) 

# files_clean_list

################################
#'## Checks
################################

## check dates
all_dates <- files_clean_list %>% 
  mutate(date = map(data, ~distinct(., report_date))) %>% 
  select(sheet, date ) %>% 
  unnest(date ) 

## dates: same dates? All should heva same number of report_date. Output should be 1 row
check1 <- all_dates %>% 
  count(report_date) %>% 
  count(n)

ifelse(nrow(check1)==1, "OK", "Problem!")

## no repeated dates? Output should be 0 row
all_dates %>% 
  add_count(sheet, report_date) %>% 
  filter(n>1) %>% 
  {ifelse(nrow(.)==0, "OK", "Problem!")}
