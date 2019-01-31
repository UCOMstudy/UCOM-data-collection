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




