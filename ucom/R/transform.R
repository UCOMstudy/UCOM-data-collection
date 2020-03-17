
#' Convert a vector to POSIXct
#'
#' @param x A vector as supported by lubridate::ymd_hm
#' @param date_format Date format to parse
#' @return POSIXct type
#' @export
convert_time <- function(x, date_format = NULL ) {
      if (lubridate::is.POSIXct(x)) {
            return(x)
      } else if (is.character(x)) {
            if (is.null(date_format)) {
                  hm_pat <- '\\s[0-9]{1,2}:[0-9]{1,2}$'
                  is_hm <- all(stringr::str_detect(x, hm_pat))
                  date_format <- dplyr::if_else(is_hm,
                                                '%Y%m%d %H%M',
                                                '%Y%m%d %H%M%S')
                  }
            out <- tryCatch(lubridate::parse_date_time(x, date_format),
                            warning = function(w) {
                                  stop('Cannot parse the Date format.')
                            })
            return(out)
      } else {
            stop('Unexpected type: ', class(x))
      }
}

#' Convert StartDate and EndDate to POSIXct
#'
#' @param df  Data frame to parse
#' @param date_format Date format to parse
#'
#' @return POSIXct type columns
#' @export
convert_start_end <- function(df, date_format = NULL) {
      out <- df %>%
            dplyr::mutate_at(dplyr::vars("startdate", "enddate"),
                             ~convert_time(., date_format))
      return(out)
}


#' Convert choice Dataframe
#'
#' @description Convert choice Dataframe to remove text.
#' @param df Data frame
#' @param var_names A vecot of variable names to convert
#' @param pattern Regex pattern to match the numbers.
#'                Default: `^(-)?[0-9]{1,5}(\\.[0-9]{1,4})?`
#' @return Converted choice data frame
#' @export
convert_choiceDF <- function(df, var_names, pattern = "^(-)?[0-9]{1,5}(\\.[0-9]{1,4})?") {

      output <- df %>%
            dplyr::mutate_at(var_names,
                             ~stringr::str_extract(., pattern))

      return(output)
}

#' Remove certain variables in a vector
#'
#' @param vars A vector of original variables
#' @param remove_vars A vector of variables to remove
#' @param pattern A regex pattern used to remove matching variables
#' @rdname remove
#' @return A vector of variables after removing
#' @export
remove <- function(vars,
                   remove_vars = NULL,
                   pattern  = NULL) {

      output <- vars
      if (!is.null(remove_vars)) {
            output <- output[!output %in% remove_vars]
      }

      if (!is.null(pattern)) {
            output <- output[!stringr::str_detect(output, pattern)]
      }

      return(output)
}

#' Remove survey general variables
#'
#' @details Refert to `ucom::gen_vars` for default variables to exclude
#' @rdname remove
#' @export
remove_gen <- function(vars) {
      output <- remove(vars,
                       ucom::gen_vars)
      return(output)
}

#' Remove text variables
#'
#' @details Refert to `ucom::text_vars` for default variables to exclude
#' @rdname remove
#' @export

remove_text <- function(vars) {
      output <- remove(vars,
                       ucom::text_vars)
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
            remove_text() %>%
            remove(pattern = pattern)
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
      rhs_country <- dplyr::enquo(country)
      code <- ucom::country_codes %>%
            dplyr::filter(!! dplyr::quo(Country) == !! rhs_country) %>%
            dplyr::pull(!! dplyr::quo(country_code))

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
      quo_code <- dplyr::enquo(code)
      quo_site <- dplyr::enquo(site)
      out_df <- df %>%
            dplyr::mutate(country = !! code,
                   site = !! site) %>%
            dplyr::select(country, site,
                          dplyr::everything())
      return(out_df)
}


#' Convert SAV, SPSS to normal CSV
#'
#' @param spss_df A SPSS data frame
#'
#' @return Converted data frame
#' @export
convert_spss <- function(spss_df) {
      temp <- fs::file_temp()

      converted_df <- spss_df %>%
            haven::as_factor() %>%
            readr::write_csv(temp)

      out <- readr::read_csv(temp, col_types = readr::cols())
      return(out)
}

#' Simple conversion of names to make them consistent
#'
#' @param df Input data frame
#' @param extra_map A named list of `new_var = old_var` for extra variable names mapping
#' @return Names converted
#' @export
convert_names <- function(df, extra_map = NULL) {
      # convert names
      message('Apply to_lower to all names...')
      out_df <- df %>%
         dplyr::rename_all(tolower)

      message('Renaming Duration_seconds...')
      out_df <- out_df %>%
            dplyr::rename(duration_seconds=dplyr::starts_with('duration'))

      message('Mapping other variables names...')
      for (i in seq_along(ucom::vars_map)) {
            var <- ucom::vars_map[[i]]
            if (var %in% colnames(out_df)) {
                  out_df <- out_df %>%
                        dplyr::rename( !!! ucom::vars_map[i])
            }
      }
      if (!is.null(extra_map)) {
            out_df <- out_df %>% dplyr::rename(!!! extra_map)
      }

      return(out_df)
}

#' Rename relevant variables to `uni` & `uni_text`
#'
#' @param df A DataFrame
#' @param site Site to check if the mapping exist
#'
#' @return A DataFrame with variable, if any, renamed to `uni`& `uni_text`
#' @export
rename_uni_vars <- function(df, site) {
   if (site %in% ucom::vars_to_change$site) {
      site_uni_mapping <- ucom::vars_to_change %>% dplyr::filter(site == !!site)
      if (! is.na(site_uni_mapping$var_to_uni)) {
         df <- df %>%
            dplyr::rename(var_to_uni = !!site_uni_mapping$var_to_uni)
      }

      if (! is.na(site_uni_mapping$var_to_uni_textbox)) {
         df <- df %>%
            dplyr::rename(var_to_uni_textbox = !!site_uni_mapping$var_to_uni_textbox)
      }
   }
   return(df)
}



#' Add new columns as with NAs if not existed
#'
#'
#' @param df Data frame
#' @param vars Vars to include or add.
#'     `vars` not existed in the data frame will be added with NAs.
#'     Existing `vars` are kept.
#'
#' @return A new Data Frame with all `vars`
#' @export
add_emp_cols <- function(df, vars) {
      cols <- colnames(df)
      extra_vars <- setdiff(vars, cols)
      vars2add <- rlang::rep_named(extra_vars, NA_character_)
      out <- df %>% dplyr::mutate(!!!vars2add)
      return(out)
}
