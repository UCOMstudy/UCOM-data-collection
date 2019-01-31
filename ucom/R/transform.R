#' Convert choice Dataframe
#'
#' @description Convert choice Dataframe to remove text.
#' @param df Data frame
#' @param var_names A vecot of variable names to convert
#'
#' @return Converted choice data frame
#' @export
convert_choiceDF <- function(df, var_names) {

      pattern <- "^[0-9]{1,5}(\\.[0-9]{1,4})?"
      extraction <- dplyr::funs(stringr::str_extract(.,
                                              pattern))

      output <- df %>%
            dplyr::mutate_at(var_names, extraction)

      return(output)
}

#' Remove certain variables in a vector
#'
#' @param vars A vector of original variables
#' @param remove_vars A vector of variables to remove
#' @rdname remove
#' @return A vector of variables after removing
#' @export
remove <- function(vars, remove_vars) {

      vars <- vars[!vars %in% remove_vars]

      return(vars)
}

#' Remove survey general variables
#'
#' @rdname remove
#' @export
remove_gen <- function(vars) {
      output <- remove(vars,
                       ucom::gen_vars)
      return(output)
}

#' Remove text variables
#'
#' @param pattern A regex pattern used to remove matching variables
#'
#' @rdname remove
#' @export

remove_text <- function(vars, pattern=NULL) {
      output <- remove(vars,
                       ucom::text_vars)
      if (!is.null(pattern)) {
            output <- output[!stringr::str_detect(output, pattern)]
      }
      return(output)
}

#' Get numeric variables
#'
#' @description Get numeric variables by
#'   remove survey general variables and text variables.
#'
#' @rdname remove
#' @export
get_num_vars <- function(vars, pattern=NULL) {
      output <- vars %>%
            remove_gen() %>%
            remove_text(pattern = pattern)
      return(output)
}

map_values <- function(values, mapping) {
      output <- values %>% stringr::str_replace_all(mapping)
      return(output)
}

#' Get country code
#'
#' @description Get country code of the country name.
#' @param country character, Name of the country
#'
#' @rdname country_code
#' @return The country code of the Country name
#' @export
get_country_code <- function(country) {

      code <- ucom::country_codes %>%
            dplyr::filter(Country == country) %>%
            dplyr::pull(country_code)

      return(code)
}

#' Add country code and site name for a data set
#'
#' @param df A Dataframe
#' @param code country code to include
#' @param site site name for the dataset
#' @return A dataframe with country code and site
#'         name added as 2 new columns
#' @rdname country_code
#' @export
create_country_and_site <- function(df, code, site) {

      out_df <- df %>%
            dplyr::mutate(country = code,
                   site = site) %>%
            dplyr::select(country, site,
                          dplyr::everything())
      return(out_df)
}
