#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message("Only has one SAV file")
message("raw_data/Netherlands_Otten/Mannen_en_vrouwen_in_de_Nederlandse_maatschappij_December 21, 2018_12.05.sav")
message('Rows dropped: 0')

choice_df <- haven::read_sav(file.path('raw_data',
                                       site, 'Mannen_en_vrouwen_in_de_Nederlandse_maatschappij_December 21, 2018_12.05.sav'))

choice_df <- choice_df %>% convert_spss() %>% convert_names()

message('=========== Fixing variable names !! ===========')
colnames(choice_df) <- colnames(choice_df) %>%
      stringr::str_replace_all(
            c(
                  '^a__(.*)$' = '\\1',
                  'communal_values__([123])' = 'values_\\1',
                  'power_values__1' = 'values_4',
                  'power_values__2' = 'values_5',
                  'power_values__3' = 'values_6',
                  'achievement_values__1' = 'values_7',
                  'achievement_values__2' = 'values_8',
                  'achievement_values__3' = 'values_9',
                  'exp_domestic4_1' = 'react_domestic_4',
                  'react_work3_4_1' = 'react_work_3',
                  'react_work3_4_2' = 'react_work_4',
                  'react_work5_1' = 'react_work_5',
                  'react_work5_2' = 'react_work_6',
                  'own_support6_1' = 'own_support_6',
                  'own_support6_2' = 'own_support_7',
                  'exp_conflict_1' = 'exp_conflict',
                  'religiosity_1' = 'religiosity',
                  'political_1' = 'political',
                  'parentleave_expectat_1' = 'parentleave_efficacy',
                  'expected_parental_le' = 'parentleave_expectat',
                  'ses_1' = 'ses',
                  '^([a-z_]+)([0-9])_1$' = '\\1_\\2',
                  '^(.*)_1\\.0$' = '\\1_4',
                  '^(.*)_2\\.0$' = '\\1_5',
                  '^(.*)_3\\.0$' = '\\1_6',
                  '^([a-z]+(_[a-z]+)?)_?1_2(_3)?_([123])' = '\\1_\\4',
                  '^(.*)4_5_6_1' = '\\1_4',
                  '^(.*)4_5_6_2' = '\\1_5',
                  '^(.*)4_5_6_3' = '\\1_6',
                  '^(.*)7_8_9_1' = '\\1_7',
                  '^(.*)7_8_9_2' = '\\1_8',
                  '^(.*)7_8_9_3' = '\\1_9'
            )
      )

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(sona_id)')

message('No check for this! Only one data set')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


