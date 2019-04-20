# UCOM-data-collection

Repository storing scripts/pipeline to perform data integrity check and aggregation for UCOM project.

## Makefile usage

The Makefile contains different subscripts to run the pipeline, render result summary, and tag/zip the aggregated file.

`pipeline` 

The `pipeline` subcommand contains different steps to setup, check, clean and aggregate the data.

- `create_src_folders`
      - Creates site folders, i.e.[./src/site-spec](./src/site-spec/), to store the cleaning script for each site. [script](./src/create_folder.R)

- `copy_template`
      - Copys the [default cleaning script](./src/integrity_check_template.R) template to all site folders.

- `check` 
      - Runs the default or site customized scripts in the site folders to verify and clean the data for each site. 
      - The intermeidate results from each site will be stored in the [cleaned_data](./cleaned_data/) folder.
      - Artifacts:
            - `<site_coordinator>.csv`: cleaned data 
            - `non_num_vars.rds`: R data object to store the non-numerical variables metadata
            - `num_vars.rds`: R data object to store the numerical variables metadata
            - `summary.rds`: R data object to store the summary statistics for the cleaned data, which will be used to create summary later on.

- `merge`: 
      - [script](./src/merge_data.R)
      - Merge the cleaned data from each site and aggregate the data. [aggregate data](./aggregated_data)
      - Artifacts:
            - `aggregated_clean.csv`
            - `non_num_unique.json`
            - `exc_vars.json`
            - `num_range.json`
- `summary`
      - [script](./src/summary.R)
      - Build a summary overview of each site's data using `summary.rds`.
      - Artifacts:
            - `summary.json`
