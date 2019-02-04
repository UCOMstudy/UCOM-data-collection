#!/usr/bin/env Rscript
options(warn = 0)
## Get all the paths
suppressMessages(library(dplyr))
message('========== Creating metadata summary ... ==========')

# get all paths
data_path <- here::here("cleaned_data")
all_sites <- fs::dir_ls('cleaned_data', type = 'directory')
site_names <- all_sites %>% fs::path_file()
raw_files <- fs::dir_ls('raw_data', type = 'file', recursive = TRUE)
raw_site_names <- raw_files %>% fs::path_dir() %>% fs::path_file()
file_names <- raw_files %>% fs::path_file()

output_path <- here::here('aggregated_data', 'summary.json')

# retrieve summary data for cleaned sites
message('Prepare...Summary for cleaned sites...')
summary_rds <-
      purrr::map(file.path(all_sites, 'summary.rds'),
                      readr::read_rds) %>%
      purrr::set_names(site_names)

col_names <- names(summary_rds[[1]])
merged_summary <- summary_rds %>%
      purrr::map_dfr(
            ~ t(as.matrix(.x)) %>%
                  tibble::as_tibble() %>%
                  purrr::set_names(col_names) %>%
                  tidyr::unnest(name, country, missing_prop, status))

message('Prepare... Raw files...')
# put source and file into one data frame
meta <- tibble::tibble(name = as.character(raw_site_names),
                       file = raw_files) %>%
      # Format of files
      dplyr::mutate(format = fs::path_ext(!! quo(file)))

# questionaries .docx for latter useage
doc <- meta %>%
      dplyr::filter(format == 'docx') %>%
      dplyr::select(-format, doc = !! quo(file))

# remove doc rows.
meta_nodoc <- meta %>% dplyr::filter(format != 'docx')

# put everything together
message('Prepare... Metadata summary ...')
meta_nested <- meta_nodoc  %>%
      add_count(name) %>%
      rename(n_files = n) %>%
      tidyr::nest(file, format)

meta_merged <- meta_nested %>%
      left_join(merged_summary, by = c('name' = 'name')) %>%
      left_join(doc, by = c('name' = 'name')) %>%
      # rearrange columns
      select(name, country,
             status, dim,
             missing_prop, doc,
             everything()) %>%
      # fill na with 0
      tidyr::replace_na(list(status = 0))

meta_final <- meta_merged %>%
      mutate(total_sites = n(),
             cleaned_sites = sum(status)) %>%
      tidyr::nest(- total_sites, - cleaned_sites,
                  .key = 'sources')


meta_final %>%
      jsonlite::write_json(output_path,
                          pretty = 2)
