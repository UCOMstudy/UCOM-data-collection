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
message("raw_data/Ireland_Bosak/UCOM data_Ireland_FINAL_19.11.2018merged.sav")
message('Rows dropped: 0')

choice_df <- haven::read_sav(file.path('raw_data',
                                       site, 'UCOM data_Ireland_FINAL_19.11.2018merged.sav'))

message('======= Create duration_seconds, startdate and enddate =======')
message('Rename `Location` to `uni`....')
choice_df <- choice_df %>% convert_spss() %>%
      dplyr::mutate(duration_seconds = NA_character_,
                    startdate = NA_character_,
                    enddate = NA_character_) %>%
      dplyr::rename(uni = Location) %>%
      convert_names()
################ Checking #####################
message('======= Filtering out error entries =======')
choice_df <-
      choice_df %>% dplyr::filter(
            parentleave_motivati_1 <= 100 | is.na(parentleave_motivati_1),
            parentleave_efficacy != '54' | is.na(parentleave_efficacy),
            real_pay_2 <= 100 | is.na(real_pay_2),
            other_child_3 != '47' | is.na(other_child_3)
      )

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)|(filter_\\$)|(major_double)|(number)|(area)|(class)')

message('No check for this! Only one data set')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


