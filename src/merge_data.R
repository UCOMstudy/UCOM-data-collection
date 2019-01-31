#!/usr/bin/env Rscript

################ Set up #####################
suppressMessages(library(ucom))

################ Loading Data #####################

message('\n\n')
message('Script: ', rprojroot::thisfile())
message('===== Setting up path =====')
data_path <- here::here("cleaned_data")
all_sites <- fs::dir_ls(data_path)

csv_path <- fs::dir_ls(all_sites, glob='*.csv')
num_vars_path <- file.path(all_sites, 'num_vars.rds')
non_num_vars_path <- file.path(all_sites, 'non_num_vars.rds')

output_dir <- here::here('aggregated_data')
# create path if not yet.
fs::dir_create(output_dir)

# output paths
output_path <- file.path(output_dir, 'aggregated_clean.csv')
num_range_path <- file.path(output_dir, 'num_range.json')
exc_vars_path <- file.path(output_dir, 'exc_vars.json')

# extra variables to contain
other_vars_path <- here::here('src', 'other_vars.json')

message('===== Loading & Merging data =====')
# extract non-numeric variables to contains in the final result
message('Other non-numeric variables:')
other_vars <- jsonlite::read_json(other_vars_path,
                                  simplifyVector = TRUE)
message('Variables: ',
        stringr::str_c(other_vars, ollapse = ', '))
message('Config file: ', other_vars_path)

# mergeing data frame frome different sources
all_dfs <- purrr::map2(csv_path,
                num_vars_path,
                ucom::read_cleaned_data,
                other_vars = other_vars)
merged_df <- dplyr::bind_rows(all_dfs)

# Integrity check: See if all numeric columns are truly numeric
num_vars <- colnames(merged_df) %>% remove(other_vars)
test_all_numeric <- merged_df %>%
      dplyr::select(num_vars) %>%
      dplyr::mutate_all(dplyr::funs(is.numeric)) %>%
      as.matrix() %>% all()
message('Is all numeric: ',
        assertthat::assert_that(test_all_numeric))

# getting the range for each numeric variables
num_range <- merged_df %>%
      dplyr::select(num_vars) %>%
      purrr::map(range, na.rm=TRUE)

# getting the variables that are not in the final data frame
non_num_vars <- purrr::map(non_num_vars_path, readr::read_rds) %>%
      purrr::flatten_chr() %>%
      unique()
exc_vars <- setdiff(non_num_vars, other_vars)

message('===== Results Summary =====')
df_dim <- dim(merged_df)
message('Data Dimension: ',
        df_dim[1], ' rows, ',
        df_dim[2], ' columns.')

message('Number of excluded variables: ', length(exc_vars))

################ Write out results #####################

message('===== Writing results =====')
message('Aggregated CSV: ', output_path)
readr::write_csv(merged_df, output_path)

message('Numeric range: ', num_range_path)
jsonlite::write_json(num_range,
                     num_range_path,
                     pretty=3)

message('Excluded variables: ', exc_vars_path)
jsonlite::write_json(exc_vars,
                     exc_vars_path,
                     pretty=3)

message('Done!')
