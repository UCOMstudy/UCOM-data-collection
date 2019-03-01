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
- convert `.` to NAs

Problem:
- `per_workhour`: range input: `48 to 56` how to convert them?
- There are three rows that may have entry errors
  - `mutated_choice_df %>% dplyr::filter(other_injunc_1 == 790 | proximal_domestic_1 == 50 | parentleave_efficacy == 50)`

## Anderson_Australia

Only has one numeric file also with text fields.

## NewZealand_McNamara

Only has one numeric file also with text fields.

## Lebanon_Saab

Citizenship all NAs

A huge amount of unrecognized variables.

- "On the whole, men ma_1" ...     ?

## Nerthlands - Otten
 A lot of variables needed to be fixed

## Italy_Fridanna

- StartDate & EndDate do not make sense: it is too big.

## Spain_Lemus

- `other_support` columns not consistent across numeric and choice df