#!/usr/bin/env Rscript
options(warn = 0)
## Get all the paths
suppressMessages(library(dplyr))

## =============== Util functions ===============
# get other vars to include
get_other_vars <- function() {
      path <- here::here('src', 'other_vars.json')
      return(jsonlite::read_json(path,
                                 simplifyVector = TRUE))
}

# check missing vars for each site
check_missing_vars <- function(site_vars) {
      other_vars <- get_other_vars()
      # not include country and site
      other_vars <- other_vars[! other_vars %in% c('country', 'site')]
      target_vars <- append(other_vars, names(ucom::num_vars))
      missing_vars <- setdiff(target_vars, site_vars)
}

# get num or non-num vars meta for each site
get_vars_meta <- function(sites, rds) {
      site_names <- sites %>% fs::path_file()

      purrr::map(file.path(sites, rds),
                 readr::read_rds) %>%
            purrr::set_names(site_names)
}
## ==============================================

message('========== Creating missing variables summary ... ==========')

# get all Cleaned data paths
data_path <- here::here("cleaned_data")
all_sites <- fs::dir_ls('cleaned_data', type = 'directory')
site_names <- all_sites %>% fs::path_file()

output_path <- here::here('aggregated_data', 'missing_vars.json')

# retrieve summary data from cleaned sites
message('Prepare variables metadata from cleaned sites...')
site_num_vars <- get_vars_meta(all_sites, 'num_vars.rds')
site_non_num_vars <- get_vars_meta(all_sites, 'non_num_vars.rds')

site_all_vars <- purrr::map2(site_num_vars,
                             site_non_num_vars,
                             ~ append(.x, .y))

message('Checking missing variables...')
missing_vars <- purrr::map(site_all_vars,
                           check_missing_vars)

message('Writing missing_vars.json')
missing_vars %>%
      jsonlite::write_json(output_path,
                           pretty = TRUE)
