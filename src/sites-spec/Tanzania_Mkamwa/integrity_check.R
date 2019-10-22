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
      message('===== Swap variable names =====')
      message('citizenship ---> immigration_background')
      message('sexual_orientation_7_TEXT ---> citizenship')
      out_df <- df %>%
         dplyr::rename(immigration_backgrou = citizenship,
                       citizenship = sexual_orientation_7_TEXT)

      out_df <- out_df %>%
            dplyr::mutate(
                  startdate = NA_character_,
                  enddate = NA_character_,
                  duration = NA_character_,
                  finished = NA_integer_
            )


      return(out_df)

}

choice_df <- get_raw_data(site, 'Choice') %>%
      custom_transform() %>%
      convert_names()
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

message('Two dataset seem to be both ChoiceValues: No checked!')

choice_df <- choice_df %>% dplyr::filter(
      other_injunc_2 != '10010',
      own_injunc_4 != '120',
      other_injunc_5 != '560',
      other_support_1 != '40',
      other_domestic_2 != '190',
      own_support_1 != '50',
      own_support_3 != '4040',
      value_fit_3 != '24',
      parentleave_efficacy != '10',
      religiosity != '8'
)
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')
