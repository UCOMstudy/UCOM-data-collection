#!/usr/bin/env Rscript

################ Set up #####################
libs <- c(
      'tidyverse',
      'rprojroot',
      'stringr',
      'here',
      'ucom'
)
invisible(
      suppressWarnings(suppressMessages(lapply(libs,
                                               library,
                                               character.only = TRUE)))
)

################ Loading Data #####################

message('\n\n')
message('Script: ', thisfile())
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric')
choice_df <- get_raw_data(site, 'Choice')

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      # 'Consent', 'id', 'Type' variable
      get_num_vars('(^Q[0-9]+)|(TEXT$)|(Consent)|(id)|(Type)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars, country_code = 'CAN')
message('Sucessfully write results!')


