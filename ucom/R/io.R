#' Input raw data
#'
#' @param site Data folder (site) name
#' @param type Numeric or Choice value data
#' @param start_row number of rows to skip meta-data (description on variables)
#' @param file_name If provided, will read in this file rather than figure out itself
#' @param sav If the data file is SPSS file. Default FALSE.
#' @rdname pipeline_io
#' @return A data frame
#' @export
get_raw_data <-
      function(site,
               type,
               start_row = 3,
               file_name = NULL,
               sav = FALSE) {
            assertthat::assert_that(type %in% c('Numeric', 'Choice'),
                                    msg = "Type should be 'Numeric' or 'Choice'")

            if (purrr::is_null(file_name)) {
                  ext <- if (sav)
                        'sav'
                  else
                        'csv'
                  file_name <-
                        stringr::str_glue('{site}_{type}Values.{ext}')
            }

            data_path <- here::here('raw_data', site, file_name)
            message("Raw Data: ", get_rel_path(data_path))
            assertthat::assert_that(fs::is_file(data_path),
                                    msg = "File doesn't exist.")
            if (sav) {
                  spss_df <- haven::read_sav(data_path)
                  df <- convert_spss(spss_df)
            } else {
                  df <- readr::read_csv(data_path, col_types = readr::cols())
            }

            # skip a description and internal id rows
            out <- df %>% dplyr::slice(start_row:dplyr::n())
            message("Rows dropped: ", (start_row - 1))
            return(out)
      }

#' Read in cleaned data for merging
#'
#' @param df_path Cleaned data path
#' @param num_vars_path Path to the related num_vars.json
#' @param other_vars Other variables to include except for numeric
#'
#' @rdname pipeline_io
#' @return A data frame
#' @export
read_cleaned_data <- function(df_path,
                              num_vars_path,
                              other_vars) {
      df <- readr::read_csv(df_path, col_types = readr::cols())
      num_vars <- readr::read_rds(num_vars_path)

      all_vars <- append(other_vars, num_vars)

      test <- dplyr::expr(df %>% dplyr::select(all_vars))

      out <- tryCatch(
            eval(test),
            error = function(e) {
                  error_path <- get_rel_path(df_path)
                  e$message <- paste('Data:',
                                     error_path,
                                     '\n',
                                     e$message,
                                     '\n Add new columns as NAs \n')
                  message(e)
                  out <- df %>%
                        add_emp_cols(all_vars) %>%
                        dplyr::select(all_vars)
            }
      )

      return(out)
}

#' Write the result: variable .rds file
#'
#' @param path path to output num_vars.rds and non_num_vars.rds
#' @param num_vars a vector of numeric variables
#' @param non_num_vars a vector of non-numeric variables
#'
#' @rdname pipeline_io
#' @return `num_vars.rds` & `non_num_vars.rds` to the output path
#' @export
write_vars_rds <- function(path,
                           num_vars,
                           non_num_vars) {
      num_vars %>% readr::write_rds(path = file.path(path, 'num_vars.rds'))
      non_num_vars %>% readr::write_rds(path = file.path(path, 'non_num_vars.rds'))
}

#' Write the result: data .csv file
#'
#' @param choice_df Choice data frame or transformed one if necessary
#' @param country_code Default NULL, if provided, will use the provided one instead of
#'      figuring out itself.
#' @param all_vars a vector of all variables
#' @rdname pipeline_io
#' @return A csv file with the site name: `site.csv`
#' @export
write_results <- function(choice_df,
                          all_vars,
                          num_vars,
                          country_code = NULL) {
      # test if all variables have benn converted to lower case
      assertthat::assert_that(all(all_vars == stringr::str_to_lower(all_vars)),
                              msg = 'Not all variables are lower case')

      # get the path
      site <- get_current_site()


      output_path <- rprojroot::find_root_file('cleaned_data',
                                               site,
                                               criterion = rprojroot::has_dir('.git'))

      table_name <-
            stringr::str_glue('{stringr::str_to_lower(site)}.csv')
      message('Output path: ', get_rel_path(output_path))
      # create new folder if not existed
      fs::dir_create(output_path)

      message("===== Data Conversion =====")
      # Convert data frame to remove unncessary text
      out_df <- choice_df %>% convert_choiceDF(num_vars)

      # Convert Date time
      out_df <- out_df %>% convert_start_end()

      # Convert `finished` to logical
      out_df <-
            out_df %>% dplyr::mutate(finished = as.logical(finished))

      message("===== Check Numeric Vars Range =====")
      check_num_range(out_df, num_vars)

      message("===== Preparing country code & site =====")
      # create country code & site
      country_collector <-
            stringr::str_split(site, '_', n = 2) %>% unlist()
      country <- country_collector[1]

      # if country code not provided
      if (purrr::is_null(country_code)) {
            if (country == 'USA') {
                  country_code <- 'USA'
            }
            else if (country %in% ucom::country_codes$Country) {
                  country_code <- get_country_code(country)
            } else {
                  stop('Country not found')
            }

            out_df <- ucom::create_country_and_site(out_df,
                                                    country_code,
                                                    site)
            # country code provided
      } else {
            out_df <- ucom::create_country_and_site(out_df,
                                                    country_code,
                                                    site)
      }

      # write data summary
      message('=== Writing data summary ===')
      non_num_vars <- setdiff(all_vars, num_vars)

      df_summary <- get_summary(out_df)
      unique_vars <- non_num_vars %>%
            remove_gen() %>%
            remove_text()
      final_summary <- c(df_summary,
                         list(unique_vars = unique_vars))
      final_summary %>%
            readr::write_rds(path = file.path(output_path, 'summary.rds'))

      # write variables
      message('=== Writing variables ===')
      write_vars_rds(path = output_path,
                     num_vars = num_vars,
                     non_num_vars = non_num_vars)

      message('Country: ', country_code)
      message('Site: ', site)
      # write out data frame
      message('=== Writing out CSV ===')
      readr::write_csv(out_df,
                       path = file.path(output_path,
                                        table_name))
}
