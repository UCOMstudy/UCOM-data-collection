#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
message('Script: ', rprojroot::thisfile())
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric', start_row = 1)
choice_df <- get_raw_data(site, 'Choice', start_row = 1, sav = TRUE)

message('===== Conver variables names =====')
message('"Duration (in seconds)"= Durationinseconds')
numeric_df <- numeric_df %>% dplyr::rename("Duration (in seconds)"= Durationinseconds)
choice_df <- choice_df %>% dplyr::rename("Duration (in seconds)"= Durationinseconds)

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^Q[0-9]+)|(TEXT)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars) %>%
      # convert to the same data types
      dplyr::mutate_at(dplyr::vars(num_vars),
                       dplyr::funs(as.numeric))
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


