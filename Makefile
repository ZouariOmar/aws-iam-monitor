# =========================================================
# aws-iam-monitor makefile
# =========================================================

# ----- Project configuration -----
PROJECT_NAME    ?= aws-iam-monitor## Project name
SRC_DIR         ?= project## Source code directory
VERSION_FILE    ?= VERSION## File storing current version
PROJECT_VERSION ?= $(shell cat $(VERSION_FILE)) ## Current project version (read from VERSION file)
DOCAPI_DIR      ?= docapi## Project api Documentention
IMAGE_NAME      ?= aws-iam-monitor## Docker image name
CONTAINER_NAME  ?= aws-iam-monitor## Docker container name
DOCKERFILE      ?= Dockerfile## Docker file
ENV_FILE        ?= $(SRC_DIR)/.env## Environment file

# Commands
RUN_CMD          ?= cd $(SRC_DIR) && ./awsctl                                     ## Run command
TEST_CMD         ?= cd $(SRC_DIR) && ./awsctl --test                              ## Test command
DOCS_CMD         ?= make -C $(DOCAPI_DIR)                                         ## Docs generation command
DOCS_SERVE_CMD   ?= cd "$(DOCAPI_DIR)/build/html" && python -m http.server 8000   ## Serve docs commmand
DOCS_DEPLOY_CMD  ?= vercel --prod $(DOCAPI_DIR)/build/html                        ## Deploy docs command
DOCS_PREVIEW_CMD ?= vercel $(DOCAPI_DIR)/build/html                               ## Preview docs command
CHANGELOG_CMD    ?= git cliff -o CHANGELOG.md                                     ## Changelog command
INIT_CMD         ?= uv venv .venv                                                 ## Init command
SYNC_CMD         ?= uv sync                                                       ## Sync command
CLEAN_CMD        ?= rm -rf .venv $(DOCAPI_DIR)/build uv.lock *.egg-info                                     ## Clean commmand
DOCKER_BUILD_CMD ?= docker build -f $(DOCKERFILE) -t $(IMAGE_NAME) .                                        ## Doocker build command
DOCKER_BASH_CMD  ?= docker run --rm -it --name $(CONTAINER_NAME) --env-file $(ENV_FILE) $(IMAGE_NAME) bash  ## Docker bash commmand
DOCKER_RUN_CMD   ?= docker run --rm --name $(CONTAINER_NAME) --env-file $(ENV_FILE) $(IMAGE_NAME)           ## Docker run commmand
DOCKER_STOP_CMD  ?= docker stop $(CONTAINER_NAME)                                                           ## Docker stop commmand
DOCKER_CLEAN_CMD ?= docker rmi $(IMAGE_NAME)                                                                ## Docker clean commmand

# Shell settings
SHELL         := /bin/bash
.DEFAULT_GOAL := all

# Colors
GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
NC     := \033[0m

# =========================================================
# Main targets
# =========================================================

.PHONY: all
all: init sync run

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

.PHONY: init
init: ## Init the project
	$(call print_title,Init $(PROJECT_NAME)...)
	@$(INIT_CMD)
	$(call print_venv)

.PHONY: sync
sync: ## Sync the project
	$(call print_title,Sync $(PROJECT_NAME)...)
	@$(SYNC_CMD)
	$(call print_venv)

.PHONY: run
run: ## Run the project
	$(call print_title,Running $(PROJECT_NAME))
	@$(RUN_CMD)

.PHONY: test
test: ## Run project tests
	$(call print_title,Testing $(PROJECT_NAME))
	@$(TEST_CMD)

.PHONY: docs
docs: docs-html ## Document the project to html

.PHONY: docs-deploy
docs-deploy: ## Deploy the project documentation
	@$(call print_title,Deploy Documentation...)
	@$(DOCS_DEPLOY_CMD)

.PHONY: docs-preview
docs-preview: docs-html ## Deploy the project documentation (preview mode)
	@$(call print_title,Preview Documentation...)
	@$(DOCS_PREVIEW_CMD)

.PHONY: docs-serve
docs-serve: ## Serve the documentation
	@$(call print_title,Serve Documentation...)
	@$(DOCS_SERVE_CMD)

docs-%: ## Document the project
	@$(call print_title,$* $(PROJECT_NAME) docsapi...)
	@$(DOCS_CMD) $*

.PHONY: clean
clean: ## Clean the project
	$(call print_title,Cleaning...)
	@$(CLEAN_CMD)

.PHONY: changelog
changelog: ## Make project changelog
	$(call print_title,Generating changelog...)
	@$(CHANGELOG_CMD)

.PHONY: docker
docker: docker-build docker-run docker-bash

.PHONY: docker-build
docker-build: ## Build the Docker image
	@$(call print_title,Build docker image...)
	@$(DOCKER_BUILD_CMD)

.PHONY: docker-bash
docker-bash: ## Open a bash shell inside the Docker container
	@$(call print_title,Open docker container bash...)
	@$(DOCKER_BASH_CMD)

.PHONY: docker-run
docker-run: ## Run awsctl inside Docker
	@$(call print_title,Run docker container...)
	@$(DOCKER_RUN_CMD)

.PHONY: docker-stop
docker-stop: ## Stop the Docker container
	@$(call print_title,Stop docker container...)
	@$(DOCKER_STOP_CMD) || true

.PHONY: docker-clean
docker-clean: ## Remove the Docker image
	@$(call print_title,Remove docker image...)
	@$(DOCKER_CLEAN_CMD) || true

# =========================================================
# Environment
# =========================================================

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

# =========================================================
# Utility
# =========================================================

define print_venv
	@echo -e "$(YELLOW)Run: source .venv/bin/activate$(NC)"
endef

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
