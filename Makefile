SRC ?= ./src
TEMPLATE ?= integrity_check_template.R
CUSTOM ?= integrity_check.R
SITES_SPEC ?= sites-spec
ALL_DIRS ?= $(SRC)/$(SITES_SPEC)/*
LOG_FILE ?= log.txt
REDIRECT ?= >>$(LOG_FILE) 2>&1 
COUNT_SCRIPTS = $(shell ls $(SRC)/$(SITES_SPEC) | wc -l)

copy_template: $(SRC)/$(TEMPLATE)
	for dir in $(ALL_DIRS); do cp $(SRC)/$(TEMPLATE) $${dir}; done

.PHONY: check
check:
	echo "Total scripts to run: $(COUNT_SCRIPTS)" > $(LOG_FILE); \
	for dir in $(ALL_DIRS); do \
		if [ -f $${dir}/$(CUSTOM) ]; then \
			Rscript $${dir}/$(CUSTOM) $(REDIRECT); \
		else \
			Rscript $${dir}/$(TEMPLATE) $(REDIRECT); \
		fi \
	done;
