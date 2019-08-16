#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric',
                           start_row = 1,
                           file_name = 'Switzerland_Haessler.csv') %>%
      dplyr::mutate(startdate = NA_character_,
                    enddate = NA_character_,
                    finished = NA_integer_) %>%
      convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(numeric_df)

pat <- '(^q[0-9]+)|(text)|(lfdn)|(swiss_part)|(filter_own_dis)|(migration)|(sexual_orientation_ot)|(filter_exp)'
num_vars <- all_vars %>%
      get_num_vars(pat)

message('No Checked! This site just contains one numeric dataset.')

numeric_df_converted_na <- numeric_df %>%
            dplyr::mutate_at(num_vars,
                             ~ ifelse(. == -77,
                                      NA_real_, .))

################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(numeric_df_converted_na, all_vars, num_vars)
message('Sucessfully write results!')


