old <- getOption("defaultPackages")

options(defaultPackages = c(old, "magrittr", "tidyverse"))

s <- sapply(options()$defaultPackages, require, character.only = TRUE)
if(!all(s)) warning("Issue with one package...")

## custom functions


cat("Welcome Matthieu!\n")
