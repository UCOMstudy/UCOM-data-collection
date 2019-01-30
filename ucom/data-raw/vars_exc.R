#!/usr/bin/env Rscript

path <- dirname(rprojroot::thisfile())
vars_exc <- jsonlite::read_json(file.path(path, 'vars_exc.json'),
                                simplifyVector = TRUE)

gen_vars <- vars_exc$gen_vars
text_vars <- vars_exc$text_vars

usethis::use_data(text_vars, overwrite = TRUE)
usethis::use_data(gen_vars, overwrite = TRUE)
