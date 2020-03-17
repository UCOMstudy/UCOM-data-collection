#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

choice_df <- get_raw_data(site, start_row = 1, 'Choice') %>%
      convert_names() %>%
      dplyr::mutate_at(dplyr::vars(startdate, enddate),
                       lubridate::as_datetime) %>%
      dplyr::mutate_all(as.character)

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(migra)|(uni)|(not)|(comme)|(relig([0-9]|ion))|(sexua)|(livin)')

message('No checking! Just one choice data set')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


