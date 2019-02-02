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
            df1 <- get('.last.error', envir = .GlobalEnv)[['numeric']]
            df2 <- get('.last.error', envir = .GlobalEnv)[['choice']]
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

}

# https://stackoverflow.com/questions/48234850/how-to-use-r-studio-view-function-programatically-in-a-package
myView <- function(x, title){
      get("View", envir = as.environment("package:utils"))(x, title)
}
