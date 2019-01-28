write_results <- function(choice_df,
                          all_vars,
                          num_vars,
                          country_code=NULL,
                          output_path=NULL) {
      # get the path
      site <- get_current_site()

      if (is_null(output_path)) {
            output_path <- find_root_file('cleaned_data',
                                          site,
                                          criterion = has_dir('.git'))
      }

      table_name <- str_glue('{stringr::str_to_lower(site)}.csv')
      message('Output path: ', output_path)
      # create new folder if not existed
      fs::dir_create(output_path)

      # Convert data frame to remove unncessary text
      out_df <- choice_df %>% convert_choiceDF(num_vars)

      # create country code & site
      country_collector <- str_split(site, '_', n=2) %>% unlist()
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

