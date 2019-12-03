#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message('Only numeric data')
message('Calculating duration_seconds & add NA for Finished col')
message('')
numeric_df <- get_raw_data(site, 'Numeric', start_row = 2) %>%
      dplyr::rename_all(.funs = stringr::str_to_lower) %>%
      convert_start_end() %>%
      dplyr::mutate(duration_seconds = enddate - startdate,
                    finished = NA) %>%
      convert_names()

message('=== Renaming column variables ===')
renamed_numeric_df <- dplyr::rename_all(numeric_df,
                                        list(~stringr::str_replace(.,
                                                                   '(.*[a-z])([0-9])$',
                                                                   '\\1_\\2'))) %>%
      dplyr::rename(exp_encouragement_1 = 'exp_encouragment',
                    proximal_domestic_5 = 'proximat_domestic_5',
                    uni = 'site',
                    parentleave_expectat = 'parentleave_expectation',
                    parentleave_efficacy = 'parentleave_efficacy',
                    parentleave_motivati_1 = 'parentleave_motivation',
                    immigration_backgrou = 'immigration_background')

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(renamed_numeric_df)

pat <- '(^[xq][0-9]+)|(text)|(respondentid)|(political_2)'
num_vars <- all_vars %>%
      get_num_vars(pat)

message('Only numeric data: NO Checked!')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(renamed_numeric_df, all_vars, num_vars,
                    country_code = get_country_code('Czech Republic'))
message('Sucessfully write results!')


