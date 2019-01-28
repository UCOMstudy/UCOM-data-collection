
get_raw_data <- function(site, type, start_row=3, file_name=NULL) {

      assertthat::assert_that(type %in% c('Numeric', 'Choice'),
                              msg = "Type should be 'Numeric' or 'Choice'")

      if (is_null(file_name)) {
            file_name <- str_glue('{site}_{type}Values.csv')
      }

      data_path <- here('raw_data', site, file_name)
      message("Raw Data: ", data_path)
      df <- read_csv(data_path, col_types = cols()) %>%
            slice(start_row:n())
      return(df)
}
