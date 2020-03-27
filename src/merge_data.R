#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
script_path <- get_rel_path(rprojroot::thisfile())
message('Script: ', script_path)
message('===== Setting up path =====')
data_path <- here::here("cleaned_data")
all_sites <- fs::dir_ls(data_path)

# input paths
csv_path <- file.path(all_sites, 'cleaned_data.csv')
num_vars_path <- file.path(all_sites, 'num_vars.rds')
non_num_vars_path <- file.path(all_sites, 'non_num_vars.rds')

output_dir <- here::here('aggregated_data')
# create path if not yet.
fs::dir_create(output_dir)

# output paths
output_path <- file.path(output_dir, 'aggregated_clean.csv')
num_range_path <- file.path(output_dir, 'num_range.json')
non_num_unique_path <- file.path(output_dir, 'non_num_unique.json')
exc_vars_path <- file.path(output_dir, 'exc_vars.json')

# extra variables to contain
other_vars_path <- here::here('src', 'other_vars.json')

message('===== Loading & Merging data =====')
# extract non-numeric variables to contains in the final result
message('Other non-numeric variables to include:')
other_vars <- jsonlite::read_json(other_vars_path,
                                  simplifyVector = TRUE)
message('Variables: ',
        stringr::str_c(other_vars, ollapse = ', '))
message('Config file: ', get_rel_path(other_vars_path))

message('Loading data sets.....')
# mergeing data frame frome different sources
all_dfs <- purrr::map2(csv_path,
                num_vars_path,
                ucom::read_cleaned_data,
                other_vars = other_vars)

# convert course numeric to character
message('**********************************************\n',
        'Do some conversions before merging.......')
converted_all_dfs <- all_dfs %>%
      purrr::map(~ dplyr::mutate_at(.x,
                                    dplyr::vars(tidyselect::all_of(other_vars)),
                                    as.character))

message('Merging all the data set....')
merged_df <- dplyr::bind_rows(converted_all_dfs)

message('Checking numeric.....')
# Integrity check: See if all numeric columns are truly numeric
num_vars <- colnames(merged_df) %>% remove(other_vars)
test_all_numeric <- merged_df %>%
      dplyr::select(tidyselect::all_of(num_vars)) %>%
      dplyr::mutate_all(is.numeric) %>%
      as.matrix() %>% all()
message('Is all numeric: ',
        assertthat::assert_that(test_all_numeric))

message('===== Results Summary =====')
df_dim <- dim(merged_df)
message('Data Dimension: ',
        df_dim[1], ' rows, ',
        df_dim[2], ' columns.')

################ Write out results #####################
#  ===========================================================
message('===== Writing results =====')
message('Numeric range: ', get_rel_path(num_range_path))

# check if there is any changes to the num_range.json files.
def_num_range <- ucom::num_vars
message('Check: same numeric range as predefined.')
ucom::check_num_range(merged_df, num_vars)

message('Writing ', fs::path_file(num_range_path),' file.')
jsonlite::write_json(def_num_range,
                     num_range_path,
                     pretty=TRUE)

#  ===========================================================
message('Aggregated CSV: ', get_rel_path(output_path))
readr::write_csv(merged_df, output_path)

#  ===========================================================
n_unique <- 100
message('Non-numeric unique values: ', get_rel_path(non_num_unique_path))
message(glue::glue('Only for unique values below {n_unique}.'))
non_num_unique <- merged_df %>%
      dplyr::select(tidyselect::all_of(-num_vars)) %>%
      purrr::map(unique)

mask <- non_num_unique %>%
      # cutoff point at 50
      purrr::map_lgl(~ length(unique(.x)) < n_unique)

non_num_unique[mask] %>%
      jsonlite::write_json(non_num_unique_path,
                           na = 'string',
                           pretty = 2)

#  ===========================================================
# getting the variables that are not in the final data frame
message('Excluded variables: ', get_rel_path(exc_vars_path))
exc_vars  <- get_exc_vars(non_num_vars_path, other_vars)
message('Number of excluded variables: ', length(unique(unlist(exc_vars))))
jsonlite::write_json(exc_vars,
                     exc_vars_path,
                     pretty=3)

message('Done!')
