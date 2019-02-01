SRC ?= ./src
TEMPLATE ?= integrity_check_template.R
CUSTOM ?= integrity_check.R
SITES_SPEC ?= sites-spec
ALL_DIRS ?= $(SRC)/$(SITES_SPEC)/*
LOG_FILE ?= log.txt
REDIRECT ?= >>$(LOG_FILE) 2>&1 
COUNT_SCRIPTS ?= $(shell ls $(SRC)/$(SITES_SPEC) | wc -l)
CRITERIA ?= "Sucessfully write results!"

# pipeline config file for R script
export R_PROFILE_USER := pipeline.rprofile

all: summary create_src_folders copy_template check merge
	echo 'Log file can be found here $(LOG_FILE)'
	
summary: $(SRC)/summary.R
	Rscript $(SRC)/summary.R

create_src_folders: $(SRC)/create_folder.R
	Rscript $(SRC)/create_folder.R

copy_template: $(SRC)/$(TEMPLATE)
	for dir in $(ALL_DIRS); do \
		cp $(SRC)/$(TEMPLATE) $${dir}; \
	done;

.PHONY: check
check:
	echo "Pipeline config file: $(R_PROFILE_USER)" > $(LOG_FILE); \
	echo "Start running....." $(REDIRECT);
	echo "\nTotal scripts to run: $(COUNT_SCRIPTS)"; \
	for dir in $(ALL_DIRS); do \
		if [ -f $${dir}/$(CUSTOM) ]; then \
			Rscript $${dir}/$(CUSTOM) $(REDIRECT); \
		else \
			Rscript $${dir}/$(TEMPLATE) $(REDIRECT); \
		fi; \
	done; \
	echo "Scripts succeeded: $$(cat $(LOG_FILE) | grep $(CRITERIA) | wc -l)";

merge: $(SRC)/merge_data.R
	Rscript $(SRC)/merge_data.R $(REDIRECT)

clean:
	rm -rf $(LOG_FILE)
	rm -rf cleaned_data/*
	rm -rf aggregated_data/*
