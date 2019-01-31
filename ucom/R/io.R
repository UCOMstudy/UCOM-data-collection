#' Input raw data
#'
#' @param site Data folder (site) name
#' @param type Numeric or Choice value data
#' @param start_row number of rows to skip meta-data (description on variables)
#' @param file_name If provided, will read in this file rather than figure out itself
#'
#' @rdname pipeline_io
#' @return A data frame
#' @export
get_raw_data <- function(site, type, start_row=3, file_name=NULL) {

      assertthat::assert_that(type %in% c('Numeric', 'Choice'),
                              msg = "Type should be 'Numeric' or 'Choice'")

      if (purrr::is_null(file_name)) {
            file_name <- stringr::str_glue('{site}_{type}Values.csv')
      }

      data_path <- here::here('raw_data', site, file_name)
      message("Raw Data: ", data_path)
      assertthat::assert_that(fs::is_file(data_path),
                              msg = "File doesn't exist.")

      df <- readr::read_csv(data_path, col_types = readr::cols()) %>%
            dplyr::slice(start_row:dplyr::n())
      message("Rows dropped: ", (start_row - 1))
      return(df)
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
      out <- df %>% dplyr::select(all_vars)
      return(out)
}

#' Write the result: variable .rds file
#'
#' @param path path to output num_vars.rds and non_num_vars.rds
#' @param all_vars a vector of all variables
#' @param num_vars a vector of numeric variables
#'
#' @rdname pipeline_io
#' @return `num_vars.rds` & `non_num_vars.rds` to the output path
#' @export
write_vars_rds <- function(path,
                           all_vars,
                           num_vars) {

      non_num_vars <- setdiff(all_vars, num_vars)

      num_vars %>% readr::write_rds(path = file.path(path, 'num_vars.rds'))
      non_num_vars %>% readr::write_rds(path = file.path(path, 'non_num_vars.rds'))
}

#' Write the result: data .csv file
#'
#' @param choice_df Choice data frame or transformed one if necessary
#' @param country_code Default NULL, if provided, will use the provided one instead of
#'      figuring out itself.
#'
#' @rdname pipeline_io
#' @return A csv file with the site name: `site.csv`
#' @export
write_results <- function(choice_df,
                          all_vars,
                          num_vars,
                          country_code=NULL) {
      # get the path
      site <- get_current_site()


      output_path <- rprojroot::find_root_file('cleaned_data',
                                               site,
                                               criterion = rprojroot::has_dir('.git'))


      table_name <- stringr::str_glue('{stringr::str_to_lower(site)}.csv')
      message('Output path: ', output_path)
      # create new folder if not existed
      fs::dir_create(output_path)

      # Convert data frame to remove unncessary text
      out_df <- choice_df %>% convert_choiceDF(num_vars)

      # create country code & site
      country_collector <- stringr::str_split(site, '_', n=2) %>% unlist()
      country <- country_collector[1]

      # if country code not provided
      if (purrr::is_null(country_code)) {
            if (country %in% ucom::country_codes$Country) {
                  country_code <- get_country_code(country)
                  out_df <- ucom::create_country_and_site(out_df,
                                                          country_code,
                                                          site)
            } else {
                  stop('Country not found')
            }
      # country code provided
      } else {
            out_df <- ucom::create_country_and_site(out_df,
                                                    country_code,
                                                    site)
      }

      # write variables
      write_vars_rds(path = output_path,
                     all_vars,
                     num_vars)

      message('Country: ', country_code)
      message('Site: ', site)
      # write out data frame
      readr::write_csv(out_df,
                       path = file.path(output_path,
                                        table_name))
}

