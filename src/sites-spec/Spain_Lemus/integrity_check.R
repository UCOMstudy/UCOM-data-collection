#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

choice_df <- get_raw_data(site, 'Choice') %>% convert_names()
numeric_df <- get_raw_data(site, 'Numeric') %>% convert_names()
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

converted_numeric_df <- numeric_df %>%
      dplyr::mutate_at(.vars = dplyr::vars(dplyr::starts_with('other_support_')),
                       .funs = function(x) dplyr::case_when(
                             x == '8' ~ '6',
                             x == '9' ~ '7',
                             TRUE ~ x
                       ))
stop()
converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(converted_numeric_df, converted_choice_df, num_vars)
message('Checked: passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


