check_equal <- function(a, b) {
      return(assertthat::assert_that(all_equal(a, b)))
}

check_identical <- function(a, b){
      return(assertthat::assert_that(isTRUE(all_equal(a, b))))
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
#' @param num_df
#' @param choice_df
#' @param vars
#'
#' @return
#' @export
#'
#' @examples
check_vars <- function(num_df, choice_df, vars) {
      vars_num <- num_df %>% select(vars)
      vars_choice <- choice_df %>% select(vars)
      tryCatch(check_identical(vars_num, vars_choice),
               error = function(e) {
                     e$message <- paste0(e$message, ". (",
                                         all.equal(vars_num, vars_choice),
                                         ").")

                     .last.error <<- list(
                           'msg' = e$message,
                           'numeric' = vars_num,
                           'choice' = vars_choice
                     )

                     stop(e)
               })
}

#' Diagnose potential error in the check
#'
#' @description Diagnose potential error from the check by comparing the
#'    choice and numeric data frames with selecting rows.
#' @param rows
#' @param cols
#' @param df1
#' @param df2
#' @param last.error
#'
#' @return
#' @export
#'
#' @examples
diagnose <- function(rows, cols=NULL, df1, df2, last.error=TRUE) {

      if (last.error) {
            df1 <- .last.error[['numeric']]
            df2 <- .last.error[['choice']]
      }

      merged_df <- df1 %>%
            slice(rows) %>%
            bind_rows(
                  df2 %>%
                        slice(rows)
            )

      if (!is.null(cols)) {
            merged_df <- merged_df %>% select(cols)
      }

      merged_df %>% View()

}
