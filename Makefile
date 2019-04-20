DATE = $$(date +'%Y-%m-%d')
TIME = $$(date +'%Y-%m-%d %H:%M:%S')

SRC ?= ./src
TEMPLATE ?= integrity_check_template.R
CUSTOM ?= integrity_check.R
SITES_SPEC ?= sites-spec
ALL_DIRS ?= $(SRC)/$(SITES_SPEC)/*
AGGREGATED_DATA ?= aggregated_data
LOG_FILE ?= log.$(DATE).txt
REDIRECT ?= >>$(LOG_FILE) 2>&1
COUNT_SCRIPTS ?= $(shell ls $(SRC)/$(SITES_SPEC) | wc -l)
# grep `log` file for this criteria to check the number of successful scripts
CRITERIA ?= "Sucessfully write results!"


# pipeline config file for R script
export R_PROFILE_USER := pipeline.rprofile

all: pipeline zip

.PHONY: summary create_src_folders copy_template check merge clean pipeline zip tag all

.ONESHELL: zip
zip: $(AGGREGATED_DATA)
	@echo "===== Building the .zip file ====="
	@-zip -ru $<.zip $<
	code=$$?
	if [ $$code -eq 12 ]; then \
		echo "Aggregated data already up-to-date."; \
	elif [ $$code -eq 0 ]; then \
		echo "\nBuilt time: $(TIME)"; \
		rm -f $<.*.zip; \
		$(MAKE) -s tag; \
	else \
		echo "Something goes wrong...."; \
	fi

tag: $(AGGREGATED_DATA).zip
	@cp $(AGGREGATED_DATA).zip $(AGGREGATED_DATA).$(DATE).zip
	echo "Tagged file: $(AGGREGATED_DATA).$(DATE).zip"

pipeline: create_src_folders copy_template check merge summary
	@echo 'Pipeline finished: log file can be found here $(LOG_FILE)'

summary: $(SRC)/summary.R
	@-Rscript $<

merge: $(SRC)/merge_data.R
	@echo "=========== Merging data ===========";
	@echo "Start time: $(TIME)"; \
	Rscript $< $(REDIRECT) && echo "Finished at: $(TIME)";

.ONESHELL: check
check: copy_template
	@echo "Pipeline config file: $(R_PROFILE_USER)" > $(LOG_FILE);
	@echo "Start running....." $(REDIRECT);
	@echo "=========== Cleaning & checking data from sites ===========";
	@echo "Start time: $(TIME)";
	@echo "Total scripts to run: $(COUNT_SCRIPTS)"; \
	for dir in $(ALL_DIRS); do \
		if [ -f $${dir}/$(CUSTOM) ]; then \
			Rscript $${dir}/$(CUSTOM) $(REDIRECT); \
		else \
			Rscript $${dir}/$(TEMPLATE) $(REDIRECT); \
		fi; \
	done;
	@echo "Scripts succeeded: $$(cat $(LOG_FILE) | grep $(CRITERIA) | wc -l)";
	@echo "Finished at: $(TIME)";

copy_template: $(SRC)/$(TEMPLATE) create_src_folders
	@echo "Copy src templates"
	@for dir in $(ALL_DIRS); do \
		cp $< $${dir}; \
	done;

create_src_folders: $(SRC)/create_folder.R
	@echo "Create src folders"
	@Rscript $<

clean:
	rm -rf $(LOG_FILE)
	rm -rf log*
	rm -rf cleaned_data/*
	rm -rf aggregated_data/*
	rm -rf aggregated_data.zip
