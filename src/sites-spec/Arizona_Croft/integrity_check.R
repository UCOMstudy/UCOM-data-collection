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

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(score)|(sc0)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')

message('===== Convert StartDate EndDate =====')
choice_df <- choice_df %>% convert_start_end('mdy HM')
message('Conversion done.')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars, country_code = 'USA')
message('Sucessfully write results!')


