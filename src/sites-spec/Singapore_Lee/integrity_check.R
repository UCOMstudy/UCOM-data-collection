#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message('==== This site only has Choice data\n',
        '(though also has a SAV file but it is the same as the choice value data )===')
choice_df <- get_raw_data(site, 'Choice') %>% convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

message('Only choice value : NO Checked!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


