#!/usr/bin/env Rscript

### Create folders based on the folders in root/raw_data

data_list <- basename(fs::dir_ls(here::here('raw_data')))
src_path <- here::here('src', 'sites-spec')
src_list <- basename(fs::dir_ls(src_path))

message('Delete outdated src folders')
del_dir <- file.path(src_path, setdiff(src_list, data_list))
fs::dir_delete(del_dir)

message('Create src folders')
ucom::create_src_folders(data_list)
