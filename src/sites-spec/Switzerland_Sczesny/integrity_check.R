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

numeric_files <- c('Switzerland_Sczesny_Part1_numeric.csv',
                   'Switzerland_Sczesny_Part2_numeric.csv')

choice_files <- c('Switzerland_Sczesny_Part1_choice.csv',
                  'Switzerland_Sczesny_Part2_choice.csv')

numeric_df <- map_dfr(numeric_files,
                      ~ get_raw_data(site, 'Numeric',
                                     file_name = .x))
choice_df <- map_dfr(choice_files,
                     ~ get_raw_data(site, 'Choice',
                                    file_name = .x))

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^Q[0-9]+)|(TEXT)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


