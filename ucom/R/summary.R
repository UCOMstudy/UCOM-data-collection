
#' Get a list of excluded variables from the merged df
#'
#' @param non_num_vars_path Path to all non-numeric variables for different sites
#' @param other_vars other non_numeric variables that are included in the merged dataframe.
#'       There variables will not be in the list of excluded variables.
#'
#' @return A list containing common  and sit-spec non-numeric variables
#' @export
get_exc_vars <- function(non_num_vars_path, other_vars) {
      sites <- fs::path_file(fs::path_dir(non_num_vars_path))
      non_num_vars <- purrr::map(non_num_vars_path, readr::read_rds)
      exc_site_spec <- non_num_vars %>%
            purrr::map(~ .x %>% remove_gen() %>% remove_text()) %>%
            purrr::set_names(sites)

      exc_common <- c(ucom::gen_vars,
                      ucom::text_vars) %>%
            remove(other_vars)

      exc_vars  <- list(common = exc_common,
                        site_spec = exc_site_spec)
      return(exc_vars)
}

#' Get summary of a cleaned data set
#'
#' @param df The cleaned data set
#' @details It contains : name, country, status (1),
#'      dimensions, and proportion of missing values
#' @return A list of summary about the data set.
#' @export
get_summary <- function(df) {
      summary <- list(
            name = unique(df$site),
            country = unique(df$country),
            status = 1,
            dim = dim(df),
            missing_prop = sum(is.na(df)) / prod(dim(df))
      )
      return(summary)
}
