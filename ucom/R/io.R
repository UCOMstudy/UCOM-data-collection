#' Input raw data
#'
#' @param site
#' @param type
#' @param start_row
#' @param file_name
#'
#' @return
#' @export
#'
#' @examples
get_raw_data <- function(site, type, start_row=3, file_name=NULL) {

      assertthat::assert_that(type %in% c('Numeric', 'Choice'),
                              msg = "Type should be 'Numeric' or 'Choice'")

      if (is_null(file_name)) {
            file_name <- str_glue('{site}_{type}Values.csv')
      }

      data_path <- here('raw_data', site, file_name)
      message("Raw Data: ", data_path)
      message("Rows dropped: ", (start_row - 1))
      df <- read_csv(data_path, col_types = cols()) %>%
            slice(start_row:n())
      return(df)
}

#' Write the result: variable .rds file
#'
#' @param path
#' @param all_vars
#' @param num_vars
#'
#' @return
#' @export
#'
#' @examples
write_vars_rds <- function(path,
                           all_vars,
                           num_vars) {

      non_num_vars <- setdiff(all_vars, num_vars)

      num_vars %>% write_rds(path = file.path(path, 'num_vars.rds'))
      non_num_vars %>% write_rds(path = file.path(path, 'non_num_vars.rds'))
}

#' Write the result: data .csv file
#'
#' @param choice_df
#' @param all_vars
#' @param num_vars
#' @param country_code
#' @param output_path
#'
#' @return
#' @export
#'
#' @examples
write_results <- function(choice_df,
                          all_vars,
                          num_vars,
                          country_code=NULL,
                          output_path=NULL) {
      # get the path
      site <- get_current_site()

      if (is_null(output_path)) {
            output_path <- rprojroot::find_root_file('cleaned_data',
                                                     site,
                                                     criterion = rprojroot::has_dir('.git'))
      }

      table_name <- str_glue('{stringr::str_to_lower(site)}.csv')
      message('Output path: ', output_path)
      # create new folder if not existed
      fs::dir_create(output_path)

      # Convert data frame to remove unncessary text
      out_df <- choice_df %>% convert_choiceDF(num_vars)

      # create country code & site
      country_collector <- stringr::str_split(site, '_', n=2) %>% unlist()
      country <- country_collector[1]

      # if country code not provided
      if (is_null(country_code)) {
            if (country %in% country_codes$Country) {

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
      write_csv(out_df, path = file.path(output_path,
                                         table_name))
}

