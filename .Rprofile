old <- getOption("defaultPackages")

remotes::install_github("MatthieuStigler/matPkg", upgrade = "never")
options(defaultPackages = c(old, "magrittr", "tidyverse", "matPkg"))

s <- sapply(options()$defaultPackages, require, character.only = TRUE)
if(!all(s)) warning("Issue with one package...")

## custom functions
gg_width <- 8
gg_height <- 5

cat("Welcome Matthieu!\n")
