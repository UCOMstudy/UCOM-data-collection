#!/usr/bin/env Rscript
options(warn = 0)
## Get all the paths
suppressMessages(library(dplyr))
message('========== Creating metadata summary ... ==========')

# get all paths
# 1. Cleaned data
data_path <- here::here("cleaned_data")
all_sites <- fs::dir_ls('cleaned_data', type = 'directory')
site_names <- all_sites %>% fs::path_file()

# 2. Raw data
raw_files <- fs::dir_ls('raw_data', type = 'file', recurse = TRUE)
raw_site_names <- raw_files %>% fs::path_dir() %>% fs::path_file()
file_names <- raw_files %>% fs::path_file()

output_path <- here::here('aggregated_data', 'summary.json')

# retrieve summary data from cleaned sites
message('Prepare summaries from cleaned sites...')
site_summaries <-
      purrr::map(file.path(all_sites, 'summary.rds'),
                 readr::read_rds) %>%
      purrr::set_names(site_names)


col_names <- names(site_summaries[[1]])
merged_summary <- site_summaries %>%
      purrr::map_dfr(
            ~ t(as.matrix(.x)) %>%
                  tibble::as_tibble() %>%
                  purrr::set_names(col_names) %>%
                  tidyr::unnest(name, country, missing_prop, status)
      )

message('Prepare raw files for summaries ...')
# put source and file into one data frame
meta <- tibble::tibble(name = as.character(raw_site_names),
                       file = file_names) %>%
      # Format of files
      dplyr::mutate(format = fs::path_ext(!!quo(file)))

# questionaries .docx for latter useage
documentations <- meta %>%
      dplyr::filter(format == 'docx') %>%
      dplyr::select(-format, doc = !!quo(file)) %>%
      tidyr::nest(doc, .key = doc)

# remove doc rows.
meta_nodoc <- meta %>% dplyr::filter(format != 'docx')


message('Prepare metadata summaries ...')
meta_nested <- meta_nodoc  %>%
      add_count(name) %>%
      rename(n_files = n) %>%
      tidyr::nest(file, format)

# put everything together
message('Merging all metadata...')
meta_merged <- meta_nested %>%
      left_join(merged_summary, by = c('name' = 'name')) %>%
      left_join(documentations, by = c('name' = 'name')) %>%
      # rearrange columns
      select(name,
             country,
             status,
             dim,
             missing_prop,
             doc,
             everything()) %>%
      # fill na with 0
      tidyr::replace_na(list(status = 0))

meta_final <- meta_merged %>%
      mutate(
            total_sites = n(),
            cleaned_sites = sum(status),
            n_obs = sum(purrr::flatten_dbl(purrr::map(dim, ~ .x[1])))
      ) %>%
      tidyr::nest(-c(total_sites,
                     cleaned_sites,
                     n_obs),
                  .key = 'sources')

message('Writing summary.json')
meta_final %>%
      jsonlite::write_json(output_path,
                           pretty = TRUE)
