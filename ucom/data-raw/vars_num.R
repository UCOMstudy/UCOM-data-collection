#!/usr/bin/env Rscript

path <- dirname(rprojroot::thisfile())
num_vars <- jsonlite::read_json(file.path(path, 'vars_num.json'),
                                simplifyVector = TRUE)

usethis::use_data(num_vars, overwrite = TRUE)

