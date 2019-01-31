# General
- `intensive_parenting_1` & `intensive_parenting_2`: has more than 90% missing values `NA`

## general demographics not to include
- expect_child,
- livingsituation
- own_distribution1
- own_distribution2
- mother_field
- father_field
- gender
- upbringing
- course
- study_year
- religion
- sexual_orientation
- citizenship
- Immigration_background
- migration_background
- ethnic_background
- marital_status
- comments
- not_use
- uni

# Site specific

## Albania_Jasini

Only has one file with text fields.

Data fixed
- variables:
  - `imEmigration_backgrou` -> `immigration_backgrou`
  - `Emigration_background` -> `migration_background`

Problem:
- `per_workhour`: range input: `48 to 56` how to convert them?
- `religiosity`: how to convert '.'? -> `NA`?
- `real_domestic_3`: how to convert '.'? -> `NA`?

## NewZealand_McNamara

Only has one numeric file also with text fields.
