#!/usr/bin/env Rscript

### Create folders based on the folders in root/raw_data

dir_list <- basename(fs::dir_ls(here::here('raw_data')))
ucom::create_src_folders(dir_list)
