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
message('===== Loading data =====')
message('Script: ', thisfile())
site <- get_current_site()

numeric_df1 <- get_raw_data(site, 'Numeric', file_name = 'Norway_Olsson_Part1_NumericValues.csv')
choice_df1 <- get_raw_data(site, 'Choice', file_name = 'Norway_Olsson_Part1_ChoiceValues.csv')

numeric_df2 <- get_raw_data(site, 'Numeric', file_name = 'Norway_Olsson_Part2_NumericValues.csv')
choice_df2 <- get_raw_data(site, 'Choice', file_name = 'Norway_Olsson_Part2_ChoiceValues.csv')

numeric_df <- bind_rows(numeric_df1, numeric_df2)
choice_df <- bind_rows(choice_df1, choice_df2)

################ Checking #####################

# cross_check(numeric_df, choice_df, text_pattern = ''(^Q[0-9]+)|(TEXT$)')

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^Q[0-9]+)|(TEXT$)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')

################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


