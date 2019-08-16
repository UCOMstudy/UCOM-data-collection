check_equal <- function(a, b) {
      return(assertthat::assert_that(dplyr::all_equal(a, b)))
}

check_identical <- function(a, b){
      return(assertthat::assert_that(isTRUE(dplyr::all_equal(a, b))))
}

check_sameCols <- function(a, b) {
      cols_a <- colnames(a)
      cols_b <- colnames(b)
      return(check_identical(cols_a, cols_b))
}


check_responseID <- function(a, b) {
      ID_a <- a$ResponseId
      ID_b <- b$ResponseId
      return(check_identical(ID_a, ID_b))
}

#' Check the range of a list of numeric variables
#'
#' @param df the data frame to check
#' @param vars numeric variables
#'
#' @return return `vars` invisibly
#' @export
#'
#' @examples
#' \dontrun{check_range(convert_choiceDF(choice_df), num_vars)}
check_num_range <- function(df, vars) {
   purrr::walk(vars, ~ check_range(df, .x))
}

#' Check the range of a numeric variable
#'
#' @description Returns error message when the value is out of range
#' @param df the data frame to check
#' @param var numeric variable
#'
#' @examples
#' \dontrun{check_range(convert_choiceDF(choice_df), 'other_support_1')}
check_range <- function(df, var) {


   num_var <- ucom::num_vars[[var]]
   if (is.null(num_var)) {
      stop(var, ' not found.')
   }

   range_min <- num_var[1]
   range_max <- num_var[2]

   quo_var <- dplyr::enquo(var)
   data_col <- df %>%
      dplyr::pull(!! quo_var) %>%
      as.numeric()
   data_min <- data_col %>% min(na.rm = TRUE)
   data_max <- data_col %>% max(na.rm = TRUE)

   if (range_min > data_min) {
      stop(glue::glue('{var} - Data min:{data_min} beyond range min:{range_min}'))
   }

   if (range_max < data_max) {
      stop(glue::glue('{var} - Data max:{data_max} beyond range max:{range_max}'))
   }
}

#' Check data integrity
#'
#' @description Check data integrity by comparing two datasets.
#' @param num_df Numeric data frame
#' @param choice_df Choice data frame
#' @param vars A vector of variables to check
#'
#' @return TRUE, or global variable `.last.error`, if exception
#' @export
check_vars <- function(num_df, choice_df, vars) {
      vars_num <- num_df %>% dplyr::select(vars)
      vars_choice <- choice_df %>% dplyr::select(vars)
      tryCatch(check_identical(vars_num, vars_choice),
               error = function(e) {
                     e$message <- paste0(e$message, ". (",
                                         dplyr::all_equal(vars_num, vars_choice),
                                         ").")

                     assign('.last.error',
                            list(
                                  'msg' = e$message,
                                  'numeric' = vars_num,
                                  'choice' = vars_choice
                            ), envir = .GlobalEnv)

                     stop(e)
               })
}

#' Diagnose potential error in the check
#'
#' @description Diagnose potential error from the check by combining to
#'    compare the choice and numeric data frames with selecting rows.
#' @param rows which row to check
#' @param cols which column to check
#' @param df1 A data frame
#' @param df2 A data frame
#' @param last.error if TRUE, the data frames will be retrived from `.last.error`
#'
#' @return A View to browse the data
#' @export
diagnose <- function(rows, cols=NULL, df1, df2, last.error=TRUE) {

      if (last.error) {
            df1 <- get('.last.error', envir = .GlobalEnv)[['numeric']] %>%
                  dplyr::mutate(.type = 'numeric')
            df2 <- get('.last.error', envir = .GlobalEnv)[['choice']] %>%
                  dplyr::mutate(.type = 'choice')
      }

      merged_df <- df1 %>%
            dplyr::slice(rows) %>%
            dplyr::bind_rows(
                  df2 %>%
                        dplyr::slice(rows)
            )

      if (!is.null(cols)) {
            merged_df <- merged_df %>% dplyr::select(cols)
      }

      merged_df %>% myView()
      return(invisible(merged_df))

}

#' Identify columns that are not consistent
#'
#' @param df DataFrame from \code{`ucom::diagnose()`}
#'
#' @return DataFrame with inconsistent columns
#' @export
get_problem_cols <- function(df) {
      return(df %>% dplyr::select(which(!df[1,] == df[2,])))
}

# https://stackoverflow.com/questions/48234850/how-to-use-r-studio-view-function-programatically-in-a-package
myView <- function(x, title){
      get("View", envir = as.environment("package:utils"))(x, title)
}
