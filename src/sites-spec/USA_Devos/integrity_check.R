#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric', start_row = 1) %>% convert_names()
choice_df <- get_raw_data(site, 'Choice', start_row = 1, sav=TRUE) %>% convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

pattern <- '(^q[0-9]+)|(text)|(site)|(source)|(icf)'
num_vars <- all_vars %>%
      # different encoding compared to other sites
      get_num_vars(pattern)

converted_choice_df <- convert_choiceDF(choice_df, num_vars) %>%
      # convert to the same data types
      dplyr::mutate_at(dplyr::vars(num_vars),
                       dplyr::funs(as.numeric))
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars, country_code = "USA")
message('Sucessfully write results!')


