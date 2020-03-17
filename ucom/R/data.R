#' A data frame of the country and country code mapping
#' @format A data frame of Countries and the corresponding country codes
"country_codes"

#' Survey general variables original - non-numeric
#' @format A vector of the survey original general variables
"org_gen_vars"

#' Survey general variables lower case - non-numeric
#' @format A vector of the survey general variables converted to lower case
"gen_vars"

#' Text variables - non-numeric
#' @format A vector of the survey text variables
"text_vars"

#' Numeric variables
#' @format A vector of the survey numeric variables
"num_vars"

#' Mapping for unusal variables names to normal variable names
#' @format A named character vector
"vars_map"

#' Mapping of variables to `uni` or `uni_textbox` for each site
#' @format A data frame with 3 variables
#' \describe{
#'   \item{site}{Site name}
#'   \item{var_to_uni}{Variable to map to `uni`}
#'   \item{var_to_uni_textbox}{Variable to map to `uni_textbox`}
#' }
"vars_to_change"


