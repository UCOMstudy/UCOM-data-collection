#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric') %>% convert_names()
choice_df <- get_raw_data(site, 'Choice') %>% convert_names()

message('===== Filter out extra rows from numeric dataset')
extra_dates <- setdiff(numeric_df$startdate, choice_df$startdate)
filtered_numeric_df <- numeric_df %>%
      dplyr::filter(!startdate %in% extra_dates)
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(filtered_numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


