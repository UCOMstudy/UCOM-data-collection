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

message('Only numeric data available for this site')
numeric_df <- get_raw_data(site, 'Numeric')

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(numeric_df)

num_vars <- all_vars %>%
      get_num_vars('(^Q[0-9]+)|(TEXT$)')

converted_numeric_df <- convert_choiceDF(numeric_df, num_vars)
check_vars(numeric_df, converted_numeric_df, num_vars)
message('NOTE: there are some variables still encoded as text')
message('Check with itself: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(numeric_df, all_vars, num_vars, country_code = 'NZL')
message('Sucessfully write results!')

