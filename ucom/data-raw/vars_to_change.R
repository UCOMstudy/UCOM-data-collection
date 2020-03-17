#!/usr/bin/env Rscript

path <- dirname(rprojroot::thisfile())
vars_to_change <- readr::read_csv(file.path(path, 'vars_to_change.csv'))

usethis::use_data(vars_to_change, overwrite = TRUE)
