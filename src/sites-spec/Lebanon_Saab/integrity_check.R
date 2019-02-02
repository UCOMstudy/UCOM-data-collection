#!/usr/bin/env Rscript

################ Set up #####################
libs <- c(
      'tidyverse',
      'rprojroot',
      'stringr',
      'here',
      'ucom'
)
invisible(
      suppressWarnings(suppressMessages(lapply(libs,
                                               library,
                                               character.only = TRUE)))
)

################ Loading Data #####################

message('\n\n')
script_path <- fs::path_rel(rprojroot::thisfile(), here::here())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

numeric_df <- get_raw_data(site, 'Numeric')
choice_df <- get_raw_data(site, 'Choice')

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      # new list of variables: "On the whole ..." and "To what extent ..."
      get_num_vars('(^Q[0-9]+)|(TEXT)|(^On the whole)|(^To what ext)')

converted_choice_df <- convert_choiceDF(choice_df, num_vars)
check_vars(numeric_df, converted_choice_df, num_vars)
message('Checked: Passed!')

message('===== Tranformation =====')
message('Add citizenship if not exist')
if (!'citizenship' %in% all_vars) {
      choice_df <- choice_df %>%
            dplyr::mutate(citizenship = NA_character_)
}
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')

