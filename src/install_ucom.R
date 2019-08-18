install_ucom_utils <- function(path) {
      devtools::check(path, error_on = 'warning')
      devtools::install(path, upgrade = 'never')
}


if (!interactive()) {
      args <- commandArgs(trailingOnly = TRUE)
      dep_path <- args[1]
      install_ucom_utils(path = dep_path)
}
