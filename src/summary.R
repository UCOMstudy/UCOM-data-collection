#!/usr/bin/env Rscript

## Get all the paths
library(magrittr)

# get all paths
all_files <- fs::dir_ls('./raw_data/', type = 'file', recursive = TRUE)
splited_path <- fs::path_split(all_files)

# put source and file into one data frame
source <- splited_path %>% purrr::map_chr(3)
file <- splited_path %>% purrr::map_chr(4)
meta <- tibble::tibble(source, file)

### Format of file


meta <- meta %>%
      dplyr::mutate(format = fs::path_ext(file))

# questionaries .docx for latter useage
doc <- meta %>%
      dplyr::filter(format == 'docx') %>%
      dplyr::select(-format, doc = file)

meta_nodoc <- meta %>% dplyr::filter(format != 'docx')

country_map <- ucom::country_codes %>%
      dplyr::select(country_code, Country)

meta_country <- meta_nodoc %>%
      dplyr::mutate(country = stringr::str_extract(source, '[:alpha:]*(?=_)'),
                    collaborator = stringr::str_extract(source, '(?<=_).*')) %>%
      # map country code
      dplyr::left_join(country_map, by = c('country' = 'Country'))

meta_nested <- meta_country %>%
      dplyr::left_join(doc) %>%
      dplyr::group_by(source, country_code, doc) %>%
      dplyr::select(-country, -collaborator) %>%
      tidyr::nest()

meta_nested %>%
      jsonlite::write_json(here::here('data_summary.json'),
                           pretty = 2,
                           na = 'null')
