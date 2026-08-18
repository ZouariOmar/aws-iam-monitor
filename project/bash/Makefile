# =========================================================
# aws-iam-monitor — Bash implementation makefile
#
# Thin wrapper around ./awsctl. Intended to be run from
# project/bash/ directly, or via `make -C project/bash <target>`
# from the repository root.
# =========================================================

# ----- Configuration -----
AWSCTL   ?= ./awsctl## Path to the awsctl CLI
TARGET   ?= all## awsctl target (iam, cloud-trail, sns, lambda, event-bridge, all)
ARGS     ?=## Extra flags passed through to awsctl (e.g. ARGS=--verbose)

EXECUTABLES := awsctl \
	lib/common lib/logger lib/requirements \
	iam/src/iamctl iam/src/policy_ctl iam/src/group_ctl iam/src/user_ctl iam/src/role_ctl \
	cloud-trail/src/cloud_trail_ctl cloud-trail/src/s3_bucket_ctl \
	sns/src/sns_ctl sns/test/topic_exists \
	event-bridge/src/event_bridge_ctl event-bridge/test/rule_exists event-bridge/test/rule_metrics \
	lambda/src/lambda_ctl \
	lambda/test/lambda-code lambda/test/lambda-config lambda/test/lambda-exists \
	lambda/test/lambda-invoke lambda/test/lambda-ip-check

# Shell settings
SHELL         := /bin/bash
.DEFAULT_GOAL := help

# Colors
BLUE   := \033[0;34m
YELLOW := \033[1;33m
NC     := \033[0m

# =========================================================
# Help
# =========================================================

.PHONY: help
help:
	@echo ""
	@echo -e "$(BLUE)Usage:$(NC) make <target> [TARGET=...] [ARGS=\"...\"]"
	@echo ""
	@echo -e "$(YELLOW)Targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?##"} {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(YELLOW)Parameters:$(NC)"
	@grep -E '^[A-Za-z_]+[[:space:]]*\?=' $(MAKEFILE_LIST) | \
	while IFS= read -r line; do \
		key=$$(echo $$line | cut -d'?' -f1 | xargs); \
		desc=$$(echo $$line | grep -o '##.*' | sed 's/##//'); \
		if [ -z "$$desc" ]; then desc="(no description)"; fi; \
		printf "  \033[36m%-15s\033[0m %s\n" "$$key" "$$desc"; \
	done
	@echo ""

# =========================================================
# Lifecycle (awsctl --up|--down|--status|--test)
# =========================================================

.PHONY: up
up: ## Provision infrastructure [TARGET=all|iam|cloud-trail|sns|lambda|event-bridge ARGS=]
	$(call print_title,awsctl --up $(TARGET))
	@$(AWSCTL) --up $(TARGET) $(ARGS)

.PHONY: up-roles
up-roles: ## Provision infrastructure including optional IAM roles [TARGET=... ARGS=]
	$(call print_title,awsctl --up $(TARGET) --role)
	@$(AWSCTL) --up $(TARGET) --role $(ARGS)

.PHONY: down
down: ## Tear down infrastructure [TARGET=all|iam|cloud-trail|sns|lambda|event-bridge ARGS=]
	$(call print_title,awsctl --down $(TARGET))
	@$(AWSCTL) --down $(TARGET) $(ARGS)

.PHONY: status
status: ## Show infrastructure status [TARGET=all|iam|cloud-trail|sns|lambda|event-bridge ARGS=]
	$(call print_title,awsctl --status $(TARGET))
	@$(AWSCTL) --status $(TARGET) $(ARGS)

.PHONY: test
test: ## Run automated test suites [TARGET=all|iam|cloud-trail|sns|lambda|event-bridge ARGS=]
	$(call print_title,awsctl --test $(TARGET))
	@$(AWSCTL) --test $(TARGET) $(ARGS)

# =========================================================
# Setup
# =========================================================

.PHONY: env
env: ## Create .env from .env.example if it does not already exist
	@cp -n .env.example .env && echo "Created .env from .env.example" || echo ".env already exists — left untouched"

.PHONY: chmod
chmod: ## Re-apply executable permissions to all CLI scripts
	$(call print_title,Applying executable permissions...)
	@chmod +x $(EXECUTABLES)

.PHONY: perms
perms: chmod ## Alias for `chmod`

# =========================================================
# Utility
# =========================================================

define print_title
	@echo -e "$(BLUE)==> $(1)$(NC)"
endef
