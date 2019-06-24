#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message('=== Creating NA startdate, enddate, duration_seconds, finished ===')
numeric_df <- get_raw_data(site, 'Numeric', start_row = 1) %>%
      dplyr::mutate(startdate = NA_character_,
                    enddate = NA_character_,
                    duration_seconds = NA_character_,
                    finished = NA) %>%
      convert_names()
choice_df <- get_raw_data(site, 'Choice', start_row = 1) %>%
      dplyr::mutate(startdate = NA_character_,
                    enddate = NA_character_,
                    duration_seconds = NA_character_,
                    finished = NA) %>%
      convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(x187)|(misc)')

message('===== Converting orientaion_1 & _2 into valid values =====')

converted_choice_df <- choice_df %>%
      dplyr::mutate_at(.vars = dplyr::vars(num_vars),
                       .funs = ~ stringr::str_extract(.,
                                                      '[0-9]{1,5}(\\.[0-9]{1,4})?'))

converted_numeric_df <- numeric_df %>%
      dplyr::mutate_at(.vars = dplyr::vars(num_vars),
                       .funs = ~ stringr::str_extract(., '[0-9]*$'))


# converted_choice_df <- convert_choiceDF(choice_df, num_vars)
# converted_numeric_df <- dplyr::mutate_all(numeric_df, .funs = as.character)
check_vars(converted_numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


