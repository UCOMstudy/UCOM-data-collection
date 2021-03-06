PKGSRC  := ucom
PKGDESCRIPTION := $(PKGSRC)/DESCRIPTION
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" $(PKGDESCRIPTION))
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" $(PKGDESCRIPTION))

DATE = $$(date +'%Y-%m-%d')
TIME = $$(date +'%Y-%m-%d %H:%M:%S')

SRC ?= ./src
TEMPLATE ?= integrity_check_template.R
CUSTOM ?= integrity_check.R
SITES_SPEC ?= sites-spec
ALL_DIRS ?= $(SRC)/$(SITES_SPEC)/*
AGGREGATED_DATA ?= aggregated_data
LOG_FILE ?= log.txt
REDIRECT ?= >>$(LOG_FILE) 2>&1
COUNT_SCRIPTS ?= $(shell ls $(SRC)/$(SITES_SPEC) | wc -l)
# grep `log` file for this criteria to check the number of successful scripts
CRITERIA ?= "Sucessfully write results!"

# ucom package build & install
check_install:
	Rscript $(SRC)/install_ucom.R $(PKGSRC)

# pipeline config file for R script
export R_PROFILE_USER := pipeline.Rprofile

.PHONY: summary create_src_folders copy_template check merge clean pipeline zip tag all merge_and_summarize

all: clean pipeline zip

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

pipeline: create_src_folders copy_template check merge_and_summarize
	@echo 'Pipeline finished: log file can be found here $(LOG_FILE)'

merge_and_summarize: merge summary check_missing_vars

check_missing_vars: $(SRC)/check_missing_vars.R
	@-Rscript $<

summary: $(SRC)/summary.R
	@-Rscript $<

merge: $(SRC)/merge_data.R
	@echo "=========== Merging data ===========";
	@echo "Start time: $(TIME)"; \
	Rscript $< $(REDIRECT) && echo "Finished at: $(TIME)";

.ONESHELL: check
check: copy_template
	@echo "$(PKGNAME) Version: $(PKGVERS)" | tee $(LOG_FILE);
	@echo "Pipeline config file: $(R_PROFILE_USER)" $(REDIRECT);
	@echo "Start time: $(TIME)" $(REDIRECT);
	@echo "Start running....." $(REDIRECT);
	@echo "=========== Cleaning & checking data from sites ===========";
	@echo "$(TIME) @ Start: total scripts to run: $(COUNT_SCRIPTS)";
	ITER=0
	for dir in $(ALL_DIRS); do \
		ITER=$$((ITER+1));
		if [ -f $${dir}/$(CUSTOM) ]; then \
			Rscript $${dir}/$(CUSTOM) $(REDIRECT); \
		else \
			Rscript $${dir}/$(TEMPLATE) $(REDIRECT); \
		fi; \
		echo "$(TIME) @ Processed file: $${ITER}/$(COUNT_SCRIPTS)";
	done;
	@echo "$(TIME) @ Finished: Scripts succeeded: $$(cat $(LOG_FILE) | grep $(CRITERIA) | wc -l)/$(COUNT_SCRIPTS)";

copy_template: $(SRC)/$(TEMPLATE) create_src_folders
	@echo "=========== Copy src templates ==========="
	@for dir in $(ALL_DIRS); do \
		cp $< $${dir}; \
	done;

create_src_folders: $(SRC)/create_folder.R
	@echo "=========== Create src folders ==========="
	@Rscript $<

clean:
	@echo "Clean up previous work cache"
	rm -rf $(LOG_FILE)
	rm -rf log*
	rm -rf cleaned_data/*
	rm -rf aggregated_data/*
	rm -rf aggregated_data.zip
