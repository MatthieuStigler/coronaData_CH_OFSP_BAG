library(matPkg)
library(tidyverse)

file_here <- "/home/matifou/Dropbox/Documents/Uni/Davis/Thesis/data/yields_RMA_lobell/code_setup"
file_out <- paste(file_here, "999_CHECK_RUN_report.csv", sep="/")


dat_files <-  mat_list_Rfiles(file_here)

dat_files

##Prob files?
dat_files %>%
  filter(!has_yaml | !has_runMat) %>% 
  filter(ext!="Rout") %>% 
  filter(!str_detect(filename, "^9"))


######################
##### Previous file
######################

is_there <- file.exists(file_out)

if(is_there) {
  df_out <- read_csv(file_out) %>%
    filter(date==max(date))
  
  dat_files_time <- dat_files %>% 
    left_join(df_out %>%
                select(filename, elapsed),
              by = "filename") %>%
    mutate(first_num = str_extract(filename, "^[0-9]") %>% as.integer) %>% 
    arrange(first_num, elapsed) %>% 
    rename(elapsed_before=elapsed)
  
  dat_files_time
  
} else {
  dat_files_time <- dat_files
}

######################
##### Run stuff
######################

scripts_run <- dat_files_time %>% 
  filter(has_yaml) %>% 
  filter(runMat_val) %>% 
  # head(2) %>% 
  mat_run_Rfiles(echo=TRUE) %>% 
  dplyr::select(-full_path)

scripts_run



######################
##### check errors
######################

## check errors
mat_99_write(scripts_run)

## export
mat_99_showErr(scripts_run, dir = file_here)

