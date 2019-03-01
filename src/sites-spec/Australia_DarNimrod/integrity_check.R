#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

data_files <- c(
      'Australia_DarNimrod_NonSONA.sav',
      'Australia_DarNimrod_SONA.sav'
)
choice_df <- purrr::map_dfr(
      data_files,
      ~ get_raw_data(
            site,
            'Choice',
            start_row = 1,
            file_name = .x,
            sav = TRUE
      ) %>%
            convert_names() %>%
            dplyr::mutate_all(list(~as.character))
)
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(incl)')
message('No check for this! Only one data set')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


