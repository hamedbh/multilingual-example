.PHONY: all data clean lint format requirements environment test help

## Build the whole pipeline
all: test clean lint requirements data

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME = test-copilot
PYTHON_VERSION = python3
VIRTUALENV_LOCATION = ./.venv
PYTHON_INTERPRETER = python3

###############################################################################
# COMMANDS                                                                    #
###############################################################################

# Use phony targets to group together multiple steps for the same aim. Here 
# `data` is a phony target that depends on `data/dataset.csv`, which in turn 
# is created by calling the script at `src/data/make_dataset.py`. If there were
# multiple datasets to create these could all be listed as dependencies of 
# `data`, e.g.:
#
# data: data/dataset1.csv data/dataset2.csv
#
# The comment after the double `##` becomes the description of the target when
# running `make` or `make help` at the command line.

# Base URL
BASE_TAXI_URL = https://d37ci6vzurychx.cloudfront.net/trip-data

# Years and months for which to download data
YEARS = $(shell seq 2018 2021)
MONTHS = $(shell seq 1 12)

# Directory to store downloaded files
TAXI_DATA_DIR = data/raw/nyc_taxi

# List of all .parquet files to download
PARQUET_FILES = $(foreach year,$(YEARS),$(foreach month,$(MONTHS),$(TAXI_DATA_DIR)/year=$(year)/month=$(month)/part-0.parquet))

# Rule to download a .parquet file
$(PARQUET_FILES):
	./download_taxi_data $@

## Make datasets
data: requirements $(PARQUET_FILES)

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src
	black --check .

## Format source code with black
format:
	black .

## Install required packages, including local/project source code	
requirements:
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt
	$(PYTHON_INTERPRETER) -m ipykernel install --user --name=$(PROJECT_NAME)
	Rscript -e "renv::restore(prompt = FALSE)"

## Set up the Python environment
environment:
	$(PYTHON_INTERPRETER) -m virtualenv \
	--python=$(PYTHON_VERSION) \
	$(VIRTUALENV_LOCATION)

## Run the tests
test:
	pytest test

###############################################################################
# Self Documenting Commands                                                   #
###############################################################################

.DEFAULT_GOAL := help

# Inspired by 
# <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')

