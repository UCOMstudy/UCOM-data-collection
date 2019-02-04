#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message("Only has one SAV file")
message('Raw Data: raw_data/Australia_Dar_Nimrod/UCOM data - clean.sav')
message('Rows dropped: 0')

choice_df <- haven::read_sav(file.path('raw_data',
                                       site, 'UCOM data - clean.sav'))
choice_df <- choice_df %>% convert_spss() %>% convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')
message('No check for this! Only one data set')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


