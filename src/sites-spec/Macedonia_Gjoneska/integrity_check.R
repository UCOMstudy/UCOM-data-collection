#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_files <- c('Macedonia_Gjoneska_HEED_Numeric.csv',
                   'Macedonia_Gjoneska_STEM_Numeric.csv')

custom_transform <- function(df) {
      df %>%
            dplyr::mutate(livingsituation = as.character(livingsituation),
                          startdate = NA_character_,
                          enddate = NA_character_,
                          duration_seconds = NA_character_,
                          finished = NA_real_) %>%
            dplyr::rename(immigration_backgrou = 'immigration_background')
}

numeric_df <- purrr::map_dfr(numeric_files,
                             ~ get_raw_data(site, 'Numeric',
                                            file_name = .x,
                                            start_row = 2) %>%
                                   custom_transform()) %>%
      convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(numeric_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(subject_id)|(institute)|(faculty)')

message('No checked! Only 2 numeric files provided.')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(numeric_df, all_vars, num_vars)
message('Sucessfully write results!')


