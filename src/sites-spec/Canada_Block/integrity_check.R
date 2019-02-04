#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_files <- c('Canada_Block_PART1_NumericValues.csv',
                   'Canada_Block_PART2_NumericValues.csv')

choice_files <- c('Canada_Block_PART1_ChoiceValues.csv',
                  'Canada_Block_PART2_ChoiceValues.csv')


numeric_df <- purrr::map_dfr(numeric_files,
                             ~ get_raw_data(site, 'Numeric',
                                            file_name = .x)) %>% convert_names()
choice_df <- purrr::map_dfr(choice_files,
                            ~ get_raw_data(site, 'Choice',
                                           file_name = .x)) %>% convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')

################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


