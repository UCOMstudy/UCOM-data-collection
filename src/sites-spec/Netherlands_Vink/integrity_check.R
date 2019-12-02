#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

choice_df <- get_raw_data(site, 'Choice', start_row = 1, sav = TRUE) %>%
      convert_names() %>%
      dplyr::rename(parentleave_expectat = parentleave_expectation,
                    exp_encouragement_1 = exp_encouragement,
                    ses = ses_1)
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

# converted_choice_df <- convert_choiceDF(choice_df, num_vars) %>%
#       # convert to the same data types
#       dplyr::mutate_at(dplyr::vars(num_vars),
#                        list(~as.numeric))
# check_vars(numeric_df, converted_choice_df, num_vars)
message('No check: only use Choice data')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


