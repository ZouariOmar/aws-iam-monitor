# =========================================================
# aws-iam-monitor makefile
# =========================================================

# ----- Project configuration -----
PROJECT_NAME    ?= aws-iam-monitor              ## Project name
BUILD_DIR       ?= build                        ## Build output directory
SRC_DIR         ?= src                          ## Source code directory
VERSION_FILE    ?= VERSION                      ## File storing current version
PROJECT_VERSION ?= $(shell cat $(VERSION_FILE)) ## Current project version (read from VERSION file)

# Commands
BUILD_CMD    ?= echo "No build step configured"    ## Build command
RUN_CMD      ?= echo "No run step configured"      ## Run command
TEST_CMD     ?= echo "No tests configured"         ## Test command
LINT_CMD     ?= echo "No lint configured"          ## Lint command
FORMAT_CMD   ?= echo "No formatter configured"     ## Format command
DOCS_CMD     ?= echo "No documentation configured" ## Docs generation command

# Docker
DOCKER_IMAGE ?= $(PROJECT_NAME):latest ## Docker image name

# Shell settings
SHELL         := /bin/bash
.DEFAULT_GOAL := help

# Colors
GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
NC     := \033[0m

# =========================================================
# Utility
# =========================================================

define print_title
	@echo -e "$(BLUE)==> $(1)$(NC)"
endef

define create_tag
	@PROJECT_VERSION=$$(cat $(VERSION_FILE)); \
	echo "Creating git tag v$$PROJECT_VERSION..."; \
	git add $(VERSION_FILE); \
	git commit -m "chore(release): v$$PROJECT_VERSION" || true; \
	git tag "v$$PROJECT_VERSION"; \
	echo "Tag v$$PROJECT_VERSION created"
endef

# =========================================================
# Main targets
# =========================================================

.PHONY: all
all: build test lint

.PHONY: help
help:
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?##"} {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

.PHONY: version-up
version-up: ## Update project version
	@$(call print_title,Current version: $(PROJECT_VERSION)); \
	read -r -p "Enter new version (e.g. 1.2.3): " NEW_VERSION; \
	if [ -z "$$NEW_VERSION" ]; then echo "Cancelled"; exit 1; fi; \
	echo "$$NEW_VERSION" > $(VERSION_FILE); \
	echo "Version updated to $$NEW_VERSION"; \
	read -r -p "Create git tag? (y/n): " CONFIRM; \
	if [ "$$CONFIRM" = "y" ] || [ "$$CONFIRM" = "Y" ]; then \
		VERSION=$$(cat $(VERSION_FILE)); \
		echo "Creating git tag v$$VERSION..."; \
		git add $(VERSION_FILE); \
		git commit -m "chore(release): v$$VERSION" || true; \
		git tag "v$$VERSION"; \
		echo "Tag created"; \
	else \
		echo "Tag skipped"; \
	fi

.PHONY: build
build: ## Build the project
	$(call print_title,Building $(PROJECT_NAME))
	@mkdir -p $(BUILD_DIR)
	@$(BUILD_CMD)

.PHONY: run
run: ## Run the project
	$(call print_title,Running $(PROJECT_NAME))
	@$(RUN_CMD)

.PHONY: test
test: ## Run project tests
	$(call print_title,Testing $(PROJECT_NAME))
	@$(TEST_CMD)

.PHONY: lint
lint: ## Lint the project
	$(call print_title,Linting $(PROJECT_NAME))
	@$(LINT_CMD)

.PHONY: format
format: ## Fromat the project
	$(call print_title,Formatting $(PROJECT_NAME))
	@$(FORMAT_CMD)

.PHONY: docs
docs: ## Document the project
	@$(call print_title,Documenting $(PROJECT_NAME))
	@$(DOCS_CMD)

.PHONY: clean
clean: ## Clean the project
	$(call print_title,Cleaning...)
	@rm -rf $(BUILD_DIR)

.PHONY: docker
docker: ## Make docker image
	$(call print_title,Building docker image...)
	@docker build -t $(DOCKER_IMAGE) .

.PHONY: docker-up
docker-up: ## Docker composer up
	docker compose up --build

.PHONY: docker-down
docker-down: ## Docker composer down
	docker compose down

.PHONY: changelog
changelog: ## Make project changelog
	$(call print_title,Generating changelog...)
	@git cliff -o CHANGELOG.md
	@echo "Done."

.PHONY: release
release: format lint test build ## Make project release
	$(call print_title,Release pipeline complete)

# =========================================================
# Environment
# =========================================================

.PHONY: print-%
print-%: ## Example: print-PROJECT_VERSION
	@printf "%-20s %s\n" "$*" "$($*)"

.PHONY: env
env: ## Print project environment(s)
	@echo ""
	@grep -E '^[A-Z_]+[[:space:]]*\?=' $(MAKEFILE_LIST) | \
	while IFS= read -r line; do \
		key=$$(echo $$line | cut -d'?' -f1 | xargs); \
		desc=$$(echo $$line | grep -o '##.*' | sed 's/##//'); \
		if [ -z "$$desc" ]; then desc="(no description)"; fi; \
		printf "  \033[36m%-20s\033[0m %s\n" "$$key" "$$desc"; \
	done
	@echo ""
