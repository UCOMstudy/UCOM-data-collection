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

convert_choiceDF <- function(df, var_names) {

      pattern <- '^([0-9]{1,3}(\\.[0-9]{1,3})?).*'
      replacement <- '\\1'
      extraction <- funs(str_replace(.,
                                     pattern,
                                     replacement))

      output <- df %>%
            mutate_at(var_names, extraction)

      return(output)
}

remove <- function(vars, remove_vars) {

      vars <- vars[!vars %in% remove_vars]

      return(vars)
}

remove_gen <- function(vars) {
      output <- remove(vars,
                       ucom::gen_vars)
      return(output)
}

remove_text <- function(vars, pattern=NULL) {
      output <- remove(vars,
                       ucom::text_vars)
      if (!is.null(pattern)) {
            output <- output[!str_detect(output, pattern)]
      }
      return(output)
}

get_num_vars <- function(vars, pattern=NULL) {
      output <- vars %>%
            remove_gen() %>%
            remove_text(pattern = pattern)
      return(output)
}

map_values <- function(values, mapping) {
      output <- values %>% str_replace_all(mapping)
      return(output)
}

