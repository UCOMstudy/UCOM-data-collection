create_folders <- function(path, folder_list) {
      walk(folder_list, function(folder) dir.create(file.path('path',
                                                              'folder')))
}

get_current_site <- function() {
      dir_path <- dirname(thisfile())
      site <- basename(dir_path)
      return(site)
}

get_country_code <- function(country) {

      code <- ucom::country_codes %>%
            filter(Country == country) %>%
            pull(country_code)

      return(code)
}

create_country_and_site <- function(df, code, site) {

      out_df <- df %>%
            mutate(country = code,
                   site = site) %>%
            select(country, site,
                   everything())
      return(out_df)
}


compare <- function(rows, cols=NULL, df1, df2, last.error=TRUE) {

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


write_vars_rds <- function(path,
                           all_vars,
                           num_vars) {
      num_vars %>% write_rds(path = file.path(path, 'num_vars.rds'))

      non_num_vars <- setdiff(all_vars, num_vars)
      non_num_vars %>% write_rds(path = file.path(path, 'non_num_vars.rds'))
}
