#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message('Only numeric data available for this site')
choice_df <- get_raw_data(site, 'Choice', start_row = 3) %>% convert_names()
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

message('Only Choice value data: NO checked!')

message('Manual convert StartDate, EndDate')
choice_df <- choice_df %>% convert_start_end('dmY HM')
message('Done')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


