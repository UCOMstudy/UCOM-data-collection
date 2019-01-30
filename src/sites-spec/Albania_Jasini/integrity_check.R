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

message('Only choice data available for this site')
file_name <- 'Albania_Jasini_Paper.xlsx'
data_path <- here("raw_data", site, file_name)
message("Raw Data: ", data_path)
start_row <- 2 # the first row is the description of the variable
message("Rows dropped: ", (start_row - 1))
choice_df <- readxl::read_xlsx(data_path) %>% slice(start_row:n())

################ Checking #####################

message('===== Checking =====')
all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      get_num_vars('(^Q[0-9]+)|(TEXT)')

# these variables have "." in as values
# solution: convert them to NA
vars2fixed <- c(
      'religiosity',
      'real_domestic_3',
      'react_domestic_3'
)
message(str_c(vars2fixed, collapse = ', '),
        ': convert "." to NA')

trans_fun <- funs(if_else(. == '.',
                           NA_character_,
                           .))

trans_choice_df <- choice_df %>%
      mutate_at(vars(vars2fixed),
                trans_fun)

converted_choice_df <- convert_choiceDF(trans_choice_df, num_vars)
check_vars(trans_choice_df, converted_choice_df, num_vars)
message('Check with itself: Passed!')

message('Manual transformation for future merging:\n',
        '1. map "gender" to "Male" ~ 1 or "Female" ~ 2')
mutated_choice_df <-
      trans_choice_df %>% mutate(gender = case_when(
            gender == "1" ~ "Male",
            gender == "2" ~ "Female"
            )
      )
message('Transformation done.')
################ Write out results #####################

message('===== Writing results =====')
ucom::write_results(choice_df, all_vars, num_vars)
message('Sucessfully write results!')


