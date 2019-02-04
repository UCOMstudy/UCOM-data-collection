#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message('Only numeric data available for this site')
numeric_df <- get_raw_data(site, 'Numeric', start_row = 1,
                          file_name = 'Anderson_Australia.csv')

message('===== Droping rows =====')
message('Dropping rows 207 and 208: variables description and internalID')
numeric_df <- numeric_df[-(207:208),]
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(numeric_df)

num_vars <- all_vars %>%
      get_num_vars('(^Q[0-9]+)|(TEXT)')

converted_numeric_df <- convert_choiceDF(numeric_df, num_vars)
check_vars(numeric_df, converted_numeric_df, num_vars)
message('NOTE: there are some variables still encoded as text')
message('Check with itself: Passed!')

message('===== Manual transformation for future merging =====\n',
        '1. transform "Finished" to logical.\n',
        '2. map "gender" to "Male" or "Female"',
        '3. Convert StartDate EndDate')
mutated_numeric_df <-
      numeric_df %>% dplyr::mutate(Finished = as.logical(Finished),
                                   gender = dplyr::case_when(
                                         gender == "1" ~ "Male",
                                         gender == "2" ~ "Female"
                                         ))
mutated_numeric_df <- mutated_numeric_df %>% convert_start_end('dmY HM')
message('Transformation done.')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(mutated_numeric_df, all_vars, num_vars)
message('Sucessfully write results!')


