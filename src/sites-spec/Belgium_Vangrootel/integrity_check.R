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

message('Script: ', thisfile())
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric')
choice_df <- get_raw_data(site, 'Choice')

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^Q[0-9]+)|(TEXT$)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)

# ('Expected parental le', 'per_leave', 'per_workhour', 'age')
# these 4 variables have text in the numeric data frame
converted_numeric_df <- convert_choiceDF(numeric_df, num_vars)
check_vars(converted_numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')

message('\n\n')
