################ Set up #####################
library(tidyverse)
library(stringr)
source('./R/check.R')

gen_vars <- read_rds('gen_vars.rds')
text_vars <- read_rds('text_vars.rds')

################ Loading Data #####################

numeric_path <- '../RawData/Ethiopia_Lemma/Ethiopia_Lemma_NumericValues.csv'
choice_path <- '../RawData/Ethiopia_Lemma/Ethiopia_Lemma_ChoiceValues.csv'

numeric_df <- read_csv(numeric_path) %>% slice(3:n())
choice_df <- read_csv(choice_path) %>% slice(3:n())

################ Checking #####################

# cross_check(numeric_df, choice_df, text_pattern = ''(^Q[0-9]+)|(TEXT$)')

all_vars <- colnames(choice_df)

num_vars <- all_vars %>%
      remove_gen() %>%
      remove_text('(^Q[0-9]+)|(TEXT$)') %>%
      remove(remove_vars)

choice_num <- choice_df %>% select(num_vars)
numeric_num <- numeric_df %>% select(num_vars)

converted_choice_num <- convert_choiceDF(choice_num, num_vars)

check_vars(numeric_num, converted_choice_num, num_vars)

################ Write out results #####################

# get the path
dir_path <- dirname(rprojroot::thisfile())
country_collector <- dir_path %>%
      str_extract('(?<=/)[^/]*$')

output_path <- str_glue('./data/cleaned_data/{country_collector}')
table_name <- str_glue('{str_to_lower(country_collector)}.csv')
message(output_path)

# write variables
write_vars_rds(path = output_path)

# write data frame
out_df <- choice_df %>% convert_choiceDF(num_vars)
write_csv(out_df, path = str_glue('{output_path}/{table_name}'))


