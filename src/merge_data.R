#!/usr/bin/env Rscript

################ Set up #####################
libs <- c(
      'tidyverse',
      'here',
      'ucom',
      'fs'
)
invisible(
      suppressWarnings(suppressMessages(lapply(libs,
                                               library,
                                               character.only = TRUE)))
)

read_data <- function(df_path,
                      num_vars_path,
                      other_vars) {
      df <- read_csv(df_path, col_types = cols())
      num_vars <- read_rds(num_vars_path)

      all_vars <- append(other_vars, num_vars)
      out <- df %>% select(all_vars)
      return(out)
}

################ Loading Data #####################

message('\n\n')
message('Script: ', rprojroot::thisfile())
message('===== Setting up path =====')
data_path <- here("cleaned_data")
all_sites <- dir_ls(data_path)

csv_path <- dir_ls(all_sites, glob='*.csv')
num_vars_path <- file.path(all_sites, 'num_vars.rds')
non_num_vars_path <- file.path(all_sites, 'non_num_vars.rds')

output_dir <- here('aggregated_data')
# create path if not yet.
dir_create(output_dir)

# output paths
output_path <- file.path(output_dir, 'aggregated_clean.csv')
num_range_path <- file.path(output_dir, 'num_range.json')
exc_vars_path <- file.path(output_dir, 'exc_vars.json')

# extra variables to contain
other_vars <- c(
      "country",
      "site",
      "ResponseId",
      "Finished",
      "gender"
)

message('===== Loading & Merging data =====')
# mergeing data frame frome different sources
all_dfs <- map2(csv_path,
                num_vars_path,
                read_data,
                other_vars = other_vars)
merged_df <- bind_rows(all_dfs)

# getting the range for each numeric variables
num_range <- merged_df %>%
      select(-other_vars) %>%
      map(range, na.rm=TRUE)

# getting the variables that are not in the final data frame
non_num_vars <- map(non_num_vars_path, read_rds) %>%
      flatten_chr() %>%
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
write_csv(merged_df, output_path)

message('Numeric range: ', num_range_path)
jsonlite::write_json(num_range,
                     num_range_path,
                     pretty=3)

message('Excluded variables: ', exc_vars_path)
jsonlite::write_json(exc_vars,
                     exc_vars_path,
                     pretty=3)

message('Done!')
