vars_map<- c(
      'expected_share_12' = 'expected_share_3',
      'intensive_parenting1' = 'intensive_parenting_1',
      'intensive_parenting2' = 'intensive_parenting_2',
      'real_parentalleave' = 'real_parentalleave_1'
)

usethis::use_data(vars_map, overwrite = TRUE)
