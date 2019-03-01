#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Loading data =====')
site <- get_current_site()

message('Only one data set available for this site')
file_name <- 'Albania_Jasini_Paper.xlsx'
data_path <- here::here("raw_data", site, file_name)
message("Raw Data: ", get_rel_path(data_path))
start_row <- 2 # the first row is the description of the variable
message("Rows dropped: ", (start_row - 1))
choice_df <- readxl::read_xlsx(data_path) %>%
      dplyr::slice(start_row:dplyr::n()) %>%
      convert_names()
################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^q[0-9]+)|(text)')

# these variables have "." in as values
# solution: convert them to NA
message('Converting "." to NA')

convert_dot <- function(x) dplyr::if_else(x == '.',
                                          NA_character_,
                                          x)
trans_choice_df <- choice_df %>%
      dplyr::mutate_all(dplyr::funs(convert_dot))

converted_choice_df <- convert_choiceDF(trans_choice_df, num_vars)
check_vars(trans_choice_df, converted_choice_df, num_vars)
message('Check with itself: Passed!')

message('Manual transformation for future merging:\n',
        '1. map "gender" to "Male" ~ 1 or "Female" ~ 2\n',
        '2. Filter rows with impossible values')
mutated_choice_df <-
      trans_choice_df %>%
      dplyr::mutate(gender = dplyr::case_when(
            gender == "1" ~ "Male",
            gender == "2" ~ "Female"
            )) %>%
      dplyr::filter(other_injunc_1 != '790' | is.na(other_injunc_1),
                    proximal_domestic_1 != '50' | is.na(proximal_domestic_1),
                    parentleave_efficacy != '50' | is.na(parentleave_efficacy))

message('Transformation done.')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(mutated_choice_df, all_vars, num_vars)
message('Sucessfully write results!')


