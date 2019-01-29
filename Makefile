SRC ?= ./src
TEMPLATE ?= integrity_check_template.R
CUSTOM ?= integrity_check.R
SITES_SPEC ?= sites-spec
ALL_DIRS ?= $(SRC)/$(SITES_SPEC)/*
LOG_FILE ?= log.txt
REDIRECT ?= >>$(LOG_FILE) 2>&1 
COUNT_SCRIPTS := $(shell ls $(SRC)/$(SITES_SPEC) | wc -l)
CRITERIA ?= "Sucessfully write results!"


create_script_folders: $(SRC)/create_folder.R
	Rscript $(SRC)/create_folder.R

copy_template: $(SRC)/$(TEMPLATE)
	for dir in $(ALL_DIRS); do cp $(SRC)/$(TEMPLATE) $${dir}; done

.PHONY: check
check: 
	echo "Start running....." > $(LOG_FILE);
	echo "\nTotal scripts to run: $(COUNT_SCRIPTS)"; \
	for dir in $(ALL_DIRS); do \
		if [ -f $${dir}/$(CUSTOM) ]; then \
			Rscript $${dir}/$(CUSTOM) $(REDIRECT); \
		else \
			Rscript $${dir}/$(TEMPLATE) $(REDIRECT); \
		fi \
	done; \
	echo "Scripts succeeded: $$(cat $(LOG_FILE) | grep $(CRITERIA) | wc -l)";
	

clean:
	rm $(LOG_FILE)