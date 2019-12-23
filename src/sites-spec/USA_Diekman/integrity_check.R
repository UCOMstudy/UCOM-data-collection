#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric') %>%
      convert_names() %>%
      dplyr::rename(real_occ_5 = real_occ_7,
                    real_occ_6 = real_occ_8 )
choice_df <- get_raw_data(site, 'Choice') %>%
      convert_names() %>%
      dplyr::rename(real_occ_5 = real_occ_7,
                    real_occ_6 = real_occ_8 )

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')

message('Parsing timestampe format')
choice_df <- convert_start_end(choice_df, '%m%d%Y %H%M')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


