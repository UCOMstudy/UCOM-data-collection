context("test-convert_choiceDF")

test_that("Extract the right numeric pattern", {
      correct_df <- tibble::tribble(
            ~a, ~b,    ~c,     ~d,   ~e,   ~f,
            NA_character_, '123', '1.23', '1', '1.2', NA_character_
      )

      test_df <- tibble::tribble(
            ~a,     ~b,    ~c,     ~d,      ~e,        ~f,
            'text', '123', '1.23', '1.sd', '1.2text ', '.'
      )
      converted_df <- convert_choiceDF(test_df, colnames(test_df))

      expect_equal(correct_df, converted_df)
})

context('test-remove_*')

test_that('remove', {
      vars <- 1:3
      remove_vars <- 1
      expect_equal(2:3, remove(vars, remove_vars))

      vars <- c('a', 'b', 'c')
      remove_vars <- c('a', 'd')
      expect_equal(c('b', 'c'),
                   remove(vars, remove_vars))
})

test_that('remove_gen', {
      vars <- c('a', 'b', 'c',
                'enddate', 'finished')
      out <-  c('a', 'b', 'c')
      expect_equal(out, remove_gen(vars))
})

test_that('remove_text', {
      vars <- c('a', 'b', 'c',
                'comments', 'citizenship')
      out <-  c('a', 'b', 'c')
      expect_equal(out, remove_text(vars))
})

test_that('get_num_vars', {
      vars <- c(
            '123',
            'migration_background',
            'status',
            'abc_test',
            'uni'
            )
      pattern <- c('(uni)|(test$)')

      testCase1 <- get_num_vars(vars)
      testCase2 <- get_num_vars(vars, pattern)

      expect_equal(testCase1, c('123', 'abc_test'))
      expect_equal(testCase2, '123')
})

context('test-create country and site columns')

test_that('Get country code based on country name', {
      country <- 'Japan'
      code <- get_country_code('Japan')

      expect_equal('JPN', code)
})

test_that('Add colums for site and country code', {
      df <- tibble::tibble(some_var = c('test', 'df'))
      code <- 'CHN'
      site <- 'test_site'

      transformed_df <- create_country_and_site(df, code, site)
      expect_equal(dim(transformed_df), 2:3)
      expect_equal(code, unique(transformed_df$country))
      expect_equal(site, unique(transformed_df$site))
})
