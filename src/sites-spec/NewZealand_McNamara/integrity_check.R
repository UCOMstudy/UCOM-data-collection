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
message('Script: ', thisfile())
message('===== Loading data =====')
site <- get_current_site()

message('Only numeric data available for this site')
numeric_df <- get_raw_data(site, 'Numeric')

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(numeric_df)

num_vars <- all_vars %>%
      # a list of "ethnic_background_DO_*" encoded as numeric
      get_num_vars('(^Q[0-9]+)|(TEXT)|(ethnic_background_DO)')

converted_numeric_df <- convert_choiceDF(numeric_df, num_vars)
check_vars(numeric_df, converted_numeric_df, num_vars)
message('NOTE: there are some variables still encoded as text')
message('Check with itself: Passed!')

message('Manual transformation for future merging:\n',
        '1. transform "Finished" to logical.\n',
        '2. map "gender" to "Male" or "Female"')
mutated_numeric_df <-
      numeric_df %>% mutate(Finished = as.logical(Finished),
                            gender = case_when(
                                  gender == "1" ~ "Male",
                                  gender == "2" ~ "Female"
                                  )
                            )
message('Transformation done.')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(mutated_numeric_df,
                    all_vars, num_vars,
                    country_code = 'NZL')
message('Sucessfully write results!')

