#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_files <- c('Geneva_Kulich_Psychology_Numeric.csv',
                   'Geneva_Science_Numeric.csv')

choice_files <- c('Geneva_Kulich_Psychology_Choice.csv',
                  'Geneva_Science_Choice.csv')

custom_transform <- function(df) {
      incorrect_encode <- '(1 = Très religieux-euse)|(1 = Très religieux\\(-euse\\))'
      correct_encode <- '7 = Très religieux-euse'
      df %>%
            dplyr::mutate(religiosity = stringr::str_replace(religiosity,
                                                             incorrect_encode,
                                                             correct_encode))
}

numeric_df <- purrr::map_dfr(numeric_files,
                             ~ get_raw_data(site, 'Numeric',
                                            file_name = .x)) %>%
      custom_transform() %>%
      convert_names()

choice_df <- purrr::map_dfr(choice_files,
                            ~ get_raw_data(site, 'Choice',
                                           file_name = .x)) %>%
      custom_transform() %>%
      convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(sample)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')

message('Parsing Date Format')
choice_df <- convert_start_end(choice_df, '%d%m%y %H%M')

################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars, country_code = "CHE")
message('Sucessfully write results!')


