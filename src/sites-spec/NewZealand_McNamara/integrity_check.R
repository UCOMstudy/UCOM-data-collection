#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
message('Script: ', rprojroot::thisfile())
message('===== Loading data =====')
site <- get_current_site()

message('Only Choice data available for this site')
choice_df <- get_raw_data(site, 'Choice') %>% convert_names()

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      # a list of "ethnic_background_DO_*" encoded as numeric
      get_num_vars('(^q[0-9]+)|(text)|(ethnic_background_do)')

message('Only Choice data: NO checked!')

################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df,
                    all_vars, num_vars,
                    country_code = 'NZL')
message('Sucessfully write results!')

