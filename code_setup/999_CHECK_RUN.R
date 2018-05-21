library(tidyverse)
library(tools)


source("/home/matifou/Dropbox/Documents/Ordi/R/Divers scripts/read_yaml.R")

dir_code <- "/home/matifou/Dropbox/Documents/Uni/Davis/Thesis/data/prices_bloom/code_setup"

## get all
dat <- data_frame(full_path =list.files(dir_code, pattern="\\.R", full.names = TRUE)) %>%
  mutate(name=basename(full_path),
         ext=file_ext(name)) %>%
  select(-full_path, full_path)

count(dat, ext)

## add more
dat_2 <- dat %>%
  mutate(number_char = str_extract(name, "([0-9]_)+") %>%
           str_replace("_$", ""),
         number = number_char %>%
           str_replace("_", "\\.") %>% 
           str_replace_all("_", "") %>%
           as.numeric(),
         yaml = map(full_path, parse_yaml),
         has_yaml=map_lgl(yaml, ~ !is_empty(.)),
         has_runMat  = map2_lgl(has_yaml, yaml, ~if(.x)  "runMat" %in% names(.y) else FALSE ),
         runMat_val = map2_lgl(has_runMat, yaml, ~if(.x)  .y$runMat else FALSE )) %>%
  select(-full_path, full_path)

dat_2

dat_2 %>%
  filter(has_yaml)

dat_2 %>%
  filter(has_runMat)

######################
##### Run more stuff
######################

##

runs <- dat_2 %>%
  filter(ext=="R" & has_yaml & has_runMat) %>%
  mutate(try = map(full_path, ~safely(source)(.)))



##3 ana runs
runs %>%
  select(-full_path) %>%
  mutate(error=map(try, ~.[["error"]]),
         has_error= map_lgl(error, ~!is.null(.)),
         error=map_chr(error, ~ifelse(is.null(.), NA, .) %>% as.character)) %>%
  filter(has_error) %>%
  pull(error)
