#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_files <- c('Sweden_Back_HEED_numeric.csv',
                   'Sweden_Back_STEM_numeric.csv')
numeric_psy <- 'Sweden_Back_Psychology_Numeric.csv'

choice_files <- c('Sweden_Back_HEED_Choice.csv',
                  'Sweden_Back_STEM_choice.csv')
choice_psy <- 'Sweden_Back_Psychology_Choice.csv'

rename_vars <- function(df) {
      df %>% dplyr::rename(marital_status = 'marital status',
                           sexual_orientation = 'sexual orientation',
                           Q78 = 'uni') # map all 'uni' to 'Q78' first for consistency,
                                        # they will be mapped back to 'uni' together later
}

numeric_df <- get_raw_data(site, 'Numeric', file_name = numeric_psy) %>%
      # rename variable for psychology
      rename_vars() %>%
      dplyr::bind_rows(
            purrr::map_dfr(numeric_files,
                           ~ get_raw_data(site, 'Numeric',
                                          file_name = .x))
      ) %>%
      convert_names()


choice_df <- get_raw_data(site, 'Choice', file_name = choice_psy) %>%
      # rename variable for psychology
      rename_vars() %>%
      dplyr::bind_rows(
            purrr::map_dfr(choice_files,
                           ~ get_raw_data(site, 'Choice',
                                          file_name = .x))
      ) %>%
      convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(immigration)')

converted_numeric_df <- numeric_df %>%
      dplyr::mutate_at(.vars = dplyr::vars(dplyr::starts_with('proximal_domestic_')),
                       .funs = function(x) dplyr::case_when(
                             x == '8' ~ '7',
                             TRUE ~ x
                       ))

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(converted_numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


