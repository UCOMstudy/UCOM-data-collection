#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

custom_transform <- function(df) {
      df %>% dplyr::rename(startdate = V8,
                    enddate = V9,
                    finished = V10) %>%
            convert_start_end() %>%
            dplyr::mutate(duration_seconds = (enddate - startdate) * 60)
}

numeric_df <- get_raw_data(site, 'Numeric', start_row = 2) %>%
      custom_transform() %>%
      convert_names()
choice_df <- get_raw_data(site, 'Choice', start_row = 2) %>%
      custom_transform() %>%
      convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(^v[0-9]+$)|(text)|(area)|(^sc[0-9])|(major)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')
