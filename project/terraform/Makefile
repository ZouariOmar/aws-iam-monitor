# =========================================================
# aws-iam-monitor — Terraform implementation makefile
#
# Thin wrapper around the terraform CLI. Intended to be run
# from project/terraform/ directly, or via
# `make -C project/terraform <target>` from the repository root.
# =========================================================

TERRAFORM ?= terraform## Path to the terraform binary
ARGS      ?=## Extra flags passed through to the terraform command (e.g. ARGS="-var-file=other.tfvars")

# Shell settings
SHELL         := /bin/bash
.DEFAULT_GOAL := help

# Colors
BLUE   := \033[0;34m
YELLOW := \033[1;33m
RED    := \033[0;31m
NC     := \033[0m

# =========================================================
# Help
# =========================================================

.PHONY: help
help:
	@echo ""
	@echo -e "$(BLUE)Usage:$(NC) make <target> [ARGS=\"...\"]"
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
# Lifecycle (init/fmt/validate/plan/apply/destroy)
# =========================================================

.PHONY: init
init: ## Initialize the Terraform working directory (downloads providers) [ARGS=]
	$(call print_title,terraform init)
	@$(TERRAFORM) init $(ARGS)

.PHONY: fmt
fmt: ## Rewrite all .tf files to canonical formatting [ARGS=]
	$(call print_title,terraform fmt -recursive)
	@$(TERRAFORM) fmt -recursive $(ARGS)

.PHONY: fmt-check
fmt-check: ## Check formatting without modifying files (CI-friendly) [ARGS=]
	$(call print_title,terraform fmt -check -recursive)
	@$(TERRAFORM) fmt -check -recursive $(ARGS)

.PHONY: validate
validate: init ## Validate configuration syntax and internal consistency [ARGS=]
	$(call print_title,terraform validate)
	@$(TERRAFORM) validate $(ARGS)

.PHONY: plan
plan: ## Show the execution plan — reads live AWS state, no changes made [ARGS="-var-file=... -target=..."]
	$(call print_title,terraform plan)
	@$(TERRAFORM) plan $(ARGS)

.PHONY: apply
apply: ## Apply the execution plan — interactive confirmation required [ARGS="-var-file=..."]
	$(call print_title,terraform apply)
	@$(TERRAFORM) apply $(ARGS)

.PHONY: apply-auto
apply-auto: ## Apply without interactive confirmation — DANGEROUS, CI use only [ARGS=]
	$(call print_title,$(RED)terraform apply -auto-approve$(NC))
	@$(TERRAFORM) apply -auto-approve $(ARGS)

.PHONY: destroy
destroy: ## Destroy all Terraform-managed infrastructure — interactive confirmation required [ARGS=]
	$(call print_title,terraform destroy)
	@$(TERRAFORM) destroy $(ARGS)

.PHONY: destroy-auto
destroy-auto: ## Destroy without interactive confirmation — DANGEROUS, CI use only [ARGS=]
	$(call print_title,$(RED)terraform destroy -auto-approve$(NC))
	@$(TERRAFORM) destroy -auto-approve $(ARGS)

.PHONY: output
output: ## Show output values from the current state [ARGS="-json"]
	$(call print_title,terraform output)
	@$(TERRAFORM) output $(ARGS)

# =========================================================
# Housekeeping
# =========================================================

.PHONY: clean
clean: ## Remove local provider cache and stray state backups (keeps lock file & tfvars)
	$(call print_title,Cleaning Terraform working directory...)
	@rm -rf .terraform
	@rm -f *.tfstate.backup

# =========================================================
# Utility
# =========================================================

define print_title
	@echo -e "$(BLUE)==> $(1)$(NC)"
endef
