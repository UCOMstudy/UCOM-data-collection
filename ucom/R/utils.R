#' Create a list of folders for each site
#'
#' @param folder_list a list of folder to create
#'
#' @export
create_src_folders <- function(folder_list) {
      path <- here::here('src', 'sites-spec', folder_list)
      fs::dir_create(path)
}

#' Get the site of the current data set
#'
#' @return name of the current site
#' @export
get_current_site <- function() {
      dir_path <- dirname(rprojroot::thisfile())
      site <- basename(dir_path)
      return(site)
}


#' Relative path to UCOM root
#'
#' @param path a file system path inside UCOM project
#'
#' @return A relative path to the UCOM project root
#' @export
get_rel_path <- function(path) {
      rel_path <- fs::path_rel(path, here::here())
      return(rel_path)
}
